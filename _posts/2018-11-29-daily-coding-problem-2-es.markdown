---
layout: post
title:  "Problema de código diario #2"
date:   2018-11-29 22:03:00 +7000
categories: coding problem
lang: es
slug: daily-coding-problem-2
page_id: daily-coding-problem-2
---

Un nuevo día y un nuevo problema por resolver:

> Dado un arreglo de enteros, regresa un nuevo arreglo tal que cada elemento en el índice i del nuevo arreglo sea el producto de todos los números del arreglo original excepto el que está en i.
> Por ejemplo, si nuestra entrada fuera [1, 2, 3, 4, 5], la salida esperada sería [120, 60, 40, 30, 24]. Si nuestra entrada fuera [3, 2, 1], la salida esperada sería [2, 3, 6].
>
> Extra: ¿y si no puedes usar división?

#### Solución

{% highlight c# %}
public class ProductsOfAllButItself
{
    public static int[] Evaluate(int[] input)
    {
        //init array with ones
        int[] res = Enumerable.Repeat(1, input.Length).ToArray();
        int zeroCount = 0;
        for (int i = 0; i < input.Length; i++) {
            //handle cases with 2 zeroes which would make
            //a zero values array and we do not need to evaluate 
            //anything else
            if(input[i] == 0) {
                zeroCount++;
            }
            if (zeroCount == 2) {
                var result = new List<int>();
                for (int j = 0; j < input.Length; j++) {
                    result.Add(0);
                }
                return result.ToArray();
            }
            for (int k = 0; k < input.Length; k++) {
                if(k == i) {
                    //multiple for all but itself
                    continue;
                }
                else {
                    res[k] = res[k] * input[i];
                }
            }
        }
        return res;
    }
}
{% endhighlight %}

### Explicación
Mi primera idea fue simple: obtener el producto total del arreglo (así haríamos una pasada O(n)) y luego hacer una última pasada para iterar sobre él otra vez, dividiendo el valor actual entre la suma, y ¡bingo! tenemos una solución O(2N)

Entonces:

totalProduct = 1 * 2 * 3 * 4 * 5 = 120

Luego dividimos cada elemento para obtener cada valor individual

* Index(0) sería 120 / 1 = 120
* Index(1) sería 120 / 2 = 60
* Index(2) sería 120 / 3 = 40
* Index(3) sería 120 / 4 = 30
* Index(4) sería 120 / 5 = 24

¡Ganancia! ¿No?

No teníamos ninguna garantía sobre los valores del arreglo, si el problema hubiera dicho que los N elementos eran valores > 1 entonces esto funcionaría. Pero si nos topamos con un solo cero aquí... la operación falla. De eso habla justo esa pequeña pista al final del problema, y es una de las razones por las que no podemos usar división para nada.

Así que ahora estamos pensando en casos extremos.

1 cero se puede manejar. Solo la posición donde está el cero se multiplicaría por todos los demás valores, entonces si en vez de eso tuviéramos 6 elementos en el arreglo de entrada [0, 1, 2, 3, 4, 5], el resultado sería [120, 0, 0, 0, 0, 0].
Para llegar a 120, todavía necesitamos iterar sobre todos los elementos excepto el actual, así que esto sigue siendo válido.

¿Y si tenemos 2 ceros?

¡Entonces la multiplicación ya ni importa! Solo necesitas regresar un arreglo de longitud input.Length lleno de ceros y listo.
Esto es lo que hice en mi código. Cuento cuántas veces me he encontrado con ceros; si es uno, está bien, de todos modos necesito iterar sobre todos los N elementos, pero si son 2, simplemente puedo descartar mis cálculos actuales y regresar un arreglo de ceros. Si no, sigo mi camino y continúo multiplicando todos los números, excepto en la iteración actual, y multiplico cada uno de ellos.

La corrida manual se vería así, recordando que en cada iteración no multiplicamos el valor actual por sí mismo:

1. Inicializamos el arreglo de resultado en [1, 1, 1, 1, 1]
2. Iterando sobre el 1, así que todo se queda igual, sigue en [1, 1, 1, 1, 1]
3. Iterando sobre el 2, ahora tenemos [2, 1, 2, 2, 2]
4. Iterando sobre el 3, ahora es [6, 3, 2, 6, 6]
5. Iterando sobre el 4 nos da [24, 12, 8, 6, 24]
6. Por último, multiplicamos por 5 y terminamos con [120, 60, 40, 30, 24]

¡Y todo esto lo hicimos en una sola pasada, así que es tiempo O(N)! (Sin contar el tiempo que usamos para inicializar nuestro arreglo de resultado con 1s)

Eso es todo por hoy. Recuerda estar al pendiente de los casos extremos cuando intentes resolver tus problemas, porque estos pueden cambiar la forma en que funciona la solución, y siempre haz preguntas para aclarar dudas. Si un entrevistador me hubiera dicho que no me preocupara por los ceros, la primera solución habría funcionado sin problemas, pero pensar en casos especiales puede llevar a cambios de diseño en nuestro algoritmo.

> Na lû e-govaned 'wîn
</content>
