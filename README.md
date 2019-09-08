# Introdução

O arquivo [DotProd.bsv](DotProd.bsv) calcula o [produto interno](https://pt.wikipedia.org/wiki/Produto_interno#Exemplos) entre dois vetores de ponto flutuante, cada um deles previamente armazenado em uma memória do tipo BRAM.

Os vetores de teste que vieram junto com esta atividade são os seguintes:

```
a = [ 1.5, 4.,   2.  ]
b = [ 2.,  0.25, 0.1 ]
```

O produto interno entre eles é `1.5 * 2. + 4. * 0.25 + 2. * 0.1`, que resulta em `4.2`.

A implementação que veio com esta atividade utiliza uma máquina de estados para fazer a conta. No estado `ReqLoad`, ela requisita às memórias o número contido no endereço atual. No estado `ReqMult`, ela solicita ao submódulo `mac` que multiplique e acumule (some com o valor atual de `result`) esses dois números. No estado `Accum`, ela grava o valor acumulado até o momento de volta no registrador `result` e verifica se já terminou de fazer a conta ou não.

O submódulo `mac` tem uma interface do tipo `Server#(Tuple4#(Maybe#(Float), Float, Float, RoundMode), Tuple2#(Float,Exception))`. Isso significa que ele recebe uma requisição que consiste em três valores de ponto flutuante (no nosso código, esses três valores são `result`, `valueA` e `valueB`), sendo que o primeiro deles é opcional (por isso está dentro de um `Maybe`), e um modo de arrendondamento (no nosso código, usamos o modo padrão, por isso escrevemos `defaultValue`). Após terminar de calcular `result + valueA * valueB`, o submódulo produz uma resposta que consiste em um número de ponto flutuante (o resultado parcial) e um possível código de exceção (no nosso código, ignoramos exceções).

Para testar o código, execute `make test`:

```
$ make test
./dotprod | ./convfloats.py
Requisitando da memória o endereço 0
Obtive da memória: 1.5000 e 2.0000, multiplicando
Valor acumulado até o momento: 3.0000
Requisitando da memória o endereço 1
Obtive da memória: 4.0000 e 0.2500, multiplicando
Valor acumulado até o momento: 4.0000
Requisitando da memória o endereço 2
Obtive da memória: 2.0000 e 0.1000, multiplicando
Valor acumulado até o momento: 4.2000

Produto interno finalizado. Resultado: 4.2000
Ciclos gastos:         36
```


# Questão 1 (conceitual)

O submódulo `mac` possui uma característica interessante: dentro dele há um *pipeline*. Isso significa que depois de pedir para ele fazer uma conta do tipo `result + valueA * valueB`, no próximo ciclo já é possível solicitar que ele comece a fazer uma nova conta com outros valores, mesmo antes da resposta à primeira conta estar pronta.

Sabendo disso, responda: Por que **não** é possível simplesmente remover a máquina de estados e transformar as regras `reqLoad`, `reqMult` e `accum` em estágios de um *pipeline*, a fim de conseguir obter o resultado final do produto interno em um número menor de ciclos?


# Questão 2 (codificação)

Suponha que, em vez de calcular o produto interno, desejemos fazer só as multiplicações. Ou seja, não queremos fazer as somas. Neste caso, você deve ser capaz de transformar as regras `reqLoad`, `reqMult` e `accum` em estágios de um *pipeline*.

Modifique seu código para fazê-lo. O resultado deve ficar parecido com:

```
Requisitando da memória o endereço 0
Requisitando da memória o endereço 1
Obtive da memória: 1.5000 e 2.0000, multiplicando
Requisitando da memória o endereço 2
Obtive da memória: 4.0000 e 0.2500, multiplicando
Obtive da memória: 2.0000 e 0.1000, multiplicando
Resultado da multiplicação: 3.0000
Resultado da multiplicação: 1.0000
Resultado da multiplicação: 0.2000
Ciclos gastos:         13
```

**Atenção** à quantidade de ciclos gastos, que deve ser menor ou igual a 13.


# Questão 3 (codificação)

Existe um operador `+` para fazer a soma entre dois números de ponto flutuante de forma combinacional. Segue abaixo um exemplo de uso desse operador:

```bluespec
let acc = result + partial;
result <= acc;
```

Esse operador não é muito usado com números de ponto flutuante pois o caminho crítico do circuito correspondente geralmente é longo demais para ser considerado aceitável.

No entanto, caso ele seja usado, é possível manter a construção de *pipeline* da questão anterior e chegar ao resultado final do produto interno, como na saída abaixo:

```
Requisitando da memória o endereço 0
Requisitando da memória o endereço 1
Obtive da memória: 1.5000 e 2.0000, multiplicando
Requisitando da memória o endereço 2
Obtive da memória: 4.0000 e 0.2500, multiplicando
Obtive da memória: 2.0000 e 0.1000, multiplicando
Resultado da multiplicação: 3.0000
Resultado da multiplicação: 1.0000
Resultado da multiplicação: 0.2000

Resultado final: 4.2000
Ciclos gastos:         13
```

Modifique seu código para fazê-lo. **Atenção** à quantidade de ciclos gastos, que deve ser menor ou igual a 13.
