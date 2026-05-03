require 'set'
require 'pastel'
require_relative 'gramatica'
require_relative 'estado'

class EarleyParser
  attr_reader :gramatica, :pastel
  
  def initialize(gramatica)
    @pastel = Pastel.new
    @gramatica = gramatica
    # Parser de Early precisa de uma regra S->S para o primeiro passo
    @gramatica.regras.unshift(Regra.new(gramatica.simbolo_inicial, [gramatica.simbolo_inicial]))
  end

  def parse(entrada)
    @tabela = Array.new(entrada.length + 1) { |indice| S.new(indice, entrada) }

    # O estado inicial precisa de um array vazio para o valor iniciar sua lista de filhos
    predict(Estado.new(@gramatica.regras[0], 0, 0, "Regra inicial", []), 0)

    puts "\nLendo os caracteres... \n\n"
    
    (0..entrada.size).each do |index|
      if (index == entrada.size)
        puts pastel.red("\n================ Posição: #{index} ================")
      else
        puts pastel.red("\n==== Caracter: #{entrada[index]}, Posição: #{index} ========")
      end
      
      until @tabela[index].empty?
        estado = @tabela[index].take!
        
        if estado.completo?
          complete(estado, index)
        else
          # checa se proximo item é um terminal
          if estado.next_symbol == entrada[index] 
            scan(estado, index)
          else
            predict(estado, index)
          end
        end
      end
    end

    puts pastel.red("\n================ Fim de predição ================\n")
    #tabela
    puts pastel.magenta(@tabela) 
    final_is_valid?(@tabela[entrada.length])
  end

  private

  def predict(estado, index)
    @gramatica.regras.each do |regra|
      if regra.esquerda == estado.next_symbol
        # Iniciamos o estado predito com um array vazio para coletar a AST
        novo_estado = Estado.new(regra, 0, index, "Predito de #{estado}", [])
        @tabela[index] << novo_estado
        puts pastel.green("[Predict] Adicionando regra #{novo_estado} de Esquerda: #{regra.esquerda} e próximo símbolo: #{estado.next_symbol}")
      end
    end
  end

  def scan(estado, index)
    valor_terminal = @tabela[index].instance_variable_get(:@entrada)[index]
    
    # copia os filhos que ja forao avaliados e adiciona o caractere atual
    filhos = estado.valor.is_a?(Array) ? estado.valor.dup : []
    filhos << valor_terminal

    novo_ponto = estado.ponto + 1
    
    if novo_ponto == estado.regra.direita.length
      valor_reduzido = reduzir_ast(estado.regra, filhos)
      prox_estado = estado.advance(index, estado, valor_reduzido)
    else
      prox_estado = estado.advance(index, estado, filhos)
    end

    @tabela[index + 1] << prox_estado
  end

  def complete(estado_completado, index)
    @tabela[estado_completado.inicio].estados.each do |estado_candidato|
      if estado_candidato.next_symbol == estado_completado.regra.esquerda
        
        filhos = estado_candidato.valor.is_a?(Array) ? estado_candidato.valor.dup : []
        filhos << estado_completado.valor

        novo_ponto = estado_candidato.ponto + 1
        
        # Se avançar este não-terminal finalmente completa o estado candidato, reduzimos!
        if novo_ponto == estado_candidato.regra.direita.length
          valor_reduzido = reduzir_ast(estado_candidato.regra, filhos)
          novo_estado = estado_candidato.complete(index-1, estado_completado, estado_candidato, valor_reduzido)
        else
          novo_estado = estado_candidato.complete(index-1, estado_completado, estado_candidato, filhos)
        end

        @tabela[index] << novo_estado
      end
    end
  end

  # função converter a lista de resultados em um Node final
  def reduzir_ast(regra, res)
    case regra.to_s
    when "E->E+T"
      return ["soma", res[0], res[2]]
    when "E->E-T"
      return ["subtracao", res[0], res[2]]
    when "T->T*U"
      return ["multiplicacao", res[0], res[2]]
    when "T->T/U"
      return ["divisao", res[0], res[2]]
    when "P->F^U"
      return ["exponenciacao", res[0], res[2]]
    when "U->-U"
      return ["negativo", res[1]]
    when "F->(E)"
      return res[1] 
    when "N->ND"
      return (res[0].to_s + res[1].to_s).to_i
    when "N->D", "D->0", "D->1", "D->2", "D->3", "D->4", "D->5", "D->6", "D->7", "D->8", "D->9"
      return res[0].to_i
    else
      return res[0]
    end
  end

  def final_is_valid?(estado_set)
    final = estado_set.estados.find do |est| 
      est.regra.esquerda == @gramatica.simbolo_inicial && est.completo? && est.inicio == 0 
    end
    
    final ? final.valor : nil
  end
end