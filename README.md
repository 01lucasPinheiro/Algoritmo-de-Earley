# Algoritmo de Earley em Ruby

Este projeto implementa o Algoritmo de Earley para o reconhecimento e análise sintática de gramáticas livres de contexto. Ele foi configurado especificamente para processar expressões matemáticas simples, construindo uma Árvore de Sintaxe Abstrata (AST) durante o processo.

## Funcionalidades

- **Reconhecimento de Gramática:** Suporta gramáticas livres de contexto genéricas, incluindo aquelas com recursão à esquerda.
- **Construção de AST:** Gera uma representação em árvore da expressão de entrada.
- **Saída Colorida:** Utiliza a gem `pastel` para destacar as etapas do algoritmo no terminal.
- **Visualização da Tabela:** Utiliza `tty-table` para exibir o estado da tabela de Earley em cada passo.

## Estrutura do Projeto

- `main.rb`: Ponto de entrada que define a gramática e a expressão de teste.
- `earley.rb`: Implementação principal do motor de processamento Earley.
- `estado.rb`: Define as classes `Estado` e `S` (conjunto de estados) usadas pelo algoritmo.
- `gramatica.rb`: Define as classes `Regra` e `Gramatica`.

## Pré-requisitos

Para rodar o projeto, você precisará das gems `pastel` e `tty-table`. Instale-as usando:

```bash
gem install pastel tty-table
```

## Como Usar

Execute o arquivo `main.rb`:

```bash
ruby main.rb
```

O programa exibirá o passo a passo da predição, escaneamento e completude para cada caractere da entrada, finalizando com a AST se a sentença for aceita.

## Exemplo de Gramática

A gramática padrão implementada suporta soma, subtração, multiplicação, divisão, exponenciação, números e parênteses, respeitando a precedência padrão.
