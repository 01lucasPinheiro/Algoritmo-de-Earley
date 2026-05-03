require 'tty-table'

class Estado
  attr_accessor :regra, :ponto, :inicio, :comentario, :valor

  def initialize(regra, ponto, inicio, comentario = '', valor = nil)
    @regra = regra
    @ponto = ponto
    @inicio = inicio # estado de Origem
    @comentario = comentario
    @valor = valor
  end

  def completo?
    ponto == regra.direita.length
  end

  def next_symbol
    regra.direita[ponto]
  end

  def advance(k, regra_anterior, valor_temrinal = nil)
    Estado.new(regra, ponto + 1, inicio, "Scan de S(#{k})(#{regra_anterior})", valor_temrinal)
  end

  def complete(k, regra1, regra2, novo_valor)
    Estado.new(regra, ponto + 1, inicio, "Completo de #{regra1} e S(#{k})(#{regra2})", novo_valor)
  end

  def ==(other)
    regra.to_s == other.regra.to_s && ponto == other.ponto && inicio == other.inicio
  end

  def eql?(other)
    regra.to_s == other.regra.to_s && ponto == other.ponto && inicio == other.inicio
  end

  def hash
    [regra.to_s, ponto, inicio].hash
  end

  def to_s
    direita = @regra.direita.join.insert(ponto, '.')
    "#{@regra.esquerda} -> #{direita}"
  end
end

class S
  attr_reader :estados, :estados_visitados

  def initialize(index, entrada)
    @index = index
    @estados = Set.new
    @estados_visitados = Set.new
    @entrada = entrada
  end

  def <<(element)
    estados << element unless estados_visitados.include?(element)
  end

  def take!
    taken = (estados - estados_visitados).take(1)
    estados_visitados << taken[0]
    taken[0]
  end

  def empty?
    (estados - estados_visitados).empty?
  end

  def to_s
    table = TTY::Table.new(header: %w[Estado Origem Comentário])
    expressao = @entrada.split('').join.insert(@index, '.')

    estados.each do |estado|
      table << [estado, estado.inicio, estado.comentario]
    end

    "==== S(#{@index}): #{expressao} ====\n#{table.render(:ascii, alignments: [:left, :center, :left])}\n"
  end
end
