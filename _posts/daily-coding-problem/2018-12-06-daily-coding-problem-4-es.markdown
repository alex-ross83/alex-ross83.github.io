---
layout: post
title:  "Daily Coding Problem # 4"
date:   2018-12-06 22:52:30 +7000
categories: coding problem
series: daily-coding-problem
lang: es
slug: daily-coding-problem-4
page_id: daily-coding-problem-4
---

¡Un nuevo problema para el post de hoy! Aquí nos estamos saltando un poco las reglas y también voy a usar un lenguaje diferente para resolver este:

> Dado un arreglo de enteros, encuentra el primer entero positivo faltante en tiempo lineal y espacio constante. En otras palabras, encuentra el entero positivo más bajo que no existe en el arreglo. El arreglo puede contener duplicados y también números negativos.
>
> Por ejemplo, la entrada [3, 4, -1, 1] debería dar 2. La entrada [1, 2, 0] debería dar 3.
> Puedes modificar el arreglo de entrada in-place.

#### Solución

Javascript:

{% highlight javascript %}

function FindNextPositiveMissingNumber(input){
  var next = 1;
  input.sort();
  for(var i = 0; i < input.length; i++){
    if(input[i] > 0){
      if(input[i] > next){
        break;
      } else {
        next = input[i] + 1;
      }
    }
  }
  return next;
}

{% endhighlight %}

### Explicación

El hecho de que digan que el arreglo se puede modificar significa que podemos hacer lo que queramos con él, así que mi solución consistió en:

1. Ordenar el arreglo de entrada
2. Iterar sobre él y para cada elemento revisar si no es un número negativo; si lo es, simplemente lo descartamos y seguimos
3. Si el número es mayor que lo que pensamos que debería ser el siguiente entero positivo, sabemos que ese siguiente entero positivo es el número que estábamos buscando.
4. Si no, le sumamos 1 al número actual, ya que debería ser el siguiente entero positivo.

Aquí nos saltamos un poco las reglas, primero usando un método integrado (built-in), lo cual es totalmente válido en las entrevistas, pero se puede aclarar antes de usarlo, es decir, una vez le di una pista a un candidato que estaba batallando para obtener el tamaño de un arreglo en un ejemplo de C++ para que usara la función sizeof y así calcular el número de elementos de un arreglo, ya que no esperaba que el candidato escribiera una implementación de bajo nivel de eso. (Por cierto, sizeof(array) / sizeof(array[0]) sería el cálculo a usar en ese caso).

Ya explicamos cómo llegamos a nuestra solución y también te recomiendo hacer preguntas para aclarar dudas. A algunas personas, como a mí, se nos complican de más las soluciones, pero dado el tiempo que tienes disponible en una sola sesión de entrevista, está totalmente bien preguntar de vez en cuando si se puede usar un método integrado, siempre y cuando sepas cómo funciona. Además, estoy bastante seguro de que el equipo con el que estás entrevistando no está usando puras operaciones de ordenamiento desarrolladas internamente, pero bueno, podría estar equivocado, ¡así que nomás pregunta!

> Na lû e-govaned 'wîn
