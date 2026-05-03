require_relative "earley"
require_relative "gramatica"

regras = [
  Regra.new('S', %w[E]),
  # E:
    Regra.new('E', %w[E + T]),
    Regra.new('E', %w[E - T]),
    Regra.new('E', %w[T]),
    # T:
    Regra.new('T', %w[T * U]),
    Regra.new('T', %w[T / U]),
    Regra.new('T', %w[U]),
    # U:
    Regra.new('U', %w[- U]),
    Regra.new('U', %w[P]),
    # P:
    Regra.new('P', %w[F ^ U]),
    Regra.new('P', %w[F]),
    # F:
    Regra.new('F', ['(', 'E', ')']),
    Regra.new('F', %w[N]),
    # N:
    Regra.new('N', %w[N D]),
    Regra.new('N', %w[D]),
    # D: numeros
    *('0'..'9').map { |d| Regra.new('D', [d]) }
]

gramatica = Gramatica.new(regras, "S")
parser = EarleyParser.new(gramatica)
input = "(2 + 4) ^ -4 / 4"
input = input.gsub(/\s+/, "")

# metodo parse retorna arvore ou nil
resultado_ast = parser.parse(input)

if resultado_ast
  puts('Aceito')
  puts "Resultado da AST:"
  p resultado_ast
else
  puts('Rejeitado')
end
