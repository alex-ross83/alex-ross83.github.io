---
layout: post
title:  "Daily Coding Problem # 1"
date:   2018-11-28 06:41:30 +0000
categories: coding problem
series: daily-coding-problem
lang: es
slug: daily-coding-problem-1
page_id: daily-coding-problem-1
---

Esta es mi versión de los ejercicios que llegan al suscribirte a [Daily Coding Problem](https://www.dailycodingproblem.com/)

El problema de hoy es:

> Dada una lista de números, regresa si dos de ellos suman k.
> Por ejemplo, dado [10, 15, 3, 7] y k de 17, regresa true ya que 10 + 7 es 17.
>
> Extra: ¿Puedes hacerlo en una sola pasada?

#### Solución

Escribí mi solución en C#:

{% highlight c# %}
public class TwoSum{
    public static bool Evaluate(int[] input, int k){
        bool result = false;
        var visitedValues = new Dictionary<int, int>();
        var complement = 0;
        for (var i = 0; i < input.Length; i++) {
            complement = k - input[i];
            if (visitedValues.ContainsKey(complement)) {
                //we found our pair, return true
                return true;
            }
            else {
                if (!visitedValues.ContainsKey(input[i])){
                        visitedValues.Add(input[i], i);
                }
            }
        }
        return result;
    }
}
{% endhighlight %}

### Explicación

La implementación básica de este programa sería iterar sobre cada elemento de la lista y calcular si dos de ellos suman la cantidad k, sin embargo comparar cada objeto de una lista de tamaño N contra todos los elementos de la misma lista nos daría un O((N-1) * (N - 1)) si ignoramos el elemento actual que estamos visitando, lo cual es casi equivalente a una comparación O(N^2) en el peor de los casos, ya que el problema nunca dijo que la lista estuviera ordenada (Insight: aclarar esto ayudaría a llegar a una solución que aproveche esa información). Piensa en una lista de solo 3 elementos [4, 3, 10] y k = 13. Calcularíamos la suma de 3 + 10 hasta la penúltima iteración. Se vería más o menos así:

* 4 + 3 = 7
* 4 + 10 = 14
* Iteramos sobre el siguiente elemento:
* 3 + 4 = 7
* 3 + 10 = 13 --> ¡Bingo!

Hicimos 4 comparaciones antes de llegar a la respuesta. Si k hubiera sido un valor diferente que no fuera alcanzable, la cosa se pondría peor porque tendríamos que iterar sobre cada elemento N - 1 veces, como lo describí antes.

Podemos hacerlo mejor que eso.

Si conocemos el valor objetivo (k), podemos guardar los valores anteriores en otra estructura, total, nunca nos dijeron que hubiera una restricción de memoria, solo que intentáramos lograrlo en una sola pasada. Obviamente esto se puede poner un poco desordenado porque ahora usaríamos potencialmente O(N) de memoria para calcularlo, pero vale la pena el compromiso porque podemos calcular el resultado en tiempo O(N)!

Cuando recorremos cada elemento, podemos:
1. Calcular cuánto necesitamos para llegar a la suma k (la variable 'complement' en mi ejemplo)
2. Si el complemento no se ha guardado antes, guardamos el valor del elemento actual.
3. Si ya habíamos visto un valor que es igual al complemento, sabemos que hay al menos dos valores que suman k, así que podemos regresar true con toda confianza en ese punto.
4. Si nunca nos topamos con el complemento de ningún elemento de la lista, podemos asegurar que no hay dos valores en la lista que sumen k y regresamos false.

El truco aquí es usar una estructura de datos que te permita revisar valores guardados y hacerlo en tiempo constante O(1). Un hashmap, o en el caso de .Net un Dictionary, es una estructura diseñada justo para esto, donde podemos buscar valores y el tiempo para encontrarlos es, en teoría, O(1). Te invito a revisar la implementación real de la [.Net Dictionary<TKey, TValue> class](https://referencesource.microsoft.com/#mscorlib/system/collections/generic/dictionary.cs,bcd13bb775d408f1) class porque está bien interesante.

¡Eso es todo por hoy! Espero que hayas aprendido algo padre hoy y recuerda siempre leer el problema dos veces antes de intentar resolverlo, y no te avientes a codear soluciones sin antes entender bien qué es lo que realmente te están pidiendo.


> Na lû e-govaned 'wîn
