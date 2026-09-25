---
layout: post
title:  "Problema de código diario #3"
date:   2018-12-05 23:21:52 +7000
categories: coding problem
lang: es
slug: daily-coding-problem
page_id: daily-coding-problem-3
---

Me tardé un poco más, pero aquí está un nuevo problema para resolver!

> Dado el nodo raíz de un árbol binario, implementa serialize(root), que serializa el árbol en un string, y deserialize(s), que deserializa el string de vuelta al árbol.
>
>Por ejemplo, dada la siguiente clase Node
>
>class Node:
>	def init(self, val, left=None, right=None):
>		self.val = val
> 		self.left = left
> 		self.right = right
>
> La siguiente prueba debería pasar:
>
> node = Node(‘root’, Node(‘left’, Node(‘left.left’)), Node(‘right’))
> assert deserialize(serialize(node)).left.left.val == ‘left.left’

Este está escrito en Python, tal como se planteó el problema.

### Solución

{% highlight python %}

class Node:
	def __init__(self, val, left=None, right=None):
		self.val = val
 		self.left = left
 		self.right = right

def serialize(node):
    if(node == None):
        return "@"
    return node.val + ',' + serialize(node.left) + ',' + serialize(node.right)

def deserialize(strNode):
    strList = iter(strNode.split(','));
    def deserializeIn():
        curVal = next(strList)
        if(curVal == "@"):
            return None
        n = Node(curVal, deserializeIn(), deserializeIn());
        return n;
    return deserializeIn()

{% endhighlight %}


Nomás por diversión también lo hice en C#:
{% highlight c# %}
public class Node
    {
        public string Value { get; set; }
        public Node Left { get; set; }
        public Node Right { get; set; }
        public Node(string val, Node left = null, Node right = null)
        {
            this.Value = val;
            this.Left = left;
            this.Right = right;
        }
    }
    public class SerializeDeserializeBinaryTree
    {
        public static string Serialize(Node input)
        {
            if(input == null) {
                return "@";
            }
            return input.Value + "," + Serialize(input.Left) + "," + Serialize(input.Right);
        }

        public static Node Deserialize(string input)
        {
            var arrInput = input.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            var iter = arrInput.GetEnumerator();
            iter.MoveNext();
            return DeserializeIn(iter);
        }
        private static Node DeserializeIn(IEnumerator en)
        {
            var currentValue = (string)en.Current;
            if(currentValue == "@") {
                return null;
            }
            var n = new Node(currentValue);
            en.MoveNext();
            n.Left = DeserializeIn(en);
            en.MoveNext();
            n.Right = DeserializeIn(en);
            return n;
        }
    }
{% endhighlight %}

### Explicación

Ambos casos usan la misma lógica. La parte de serialización se hace llamando recursivamente a la misma función, y esto es lo que hace:

* Si el nodo es null, lo cual significaría que el nodo anterior no tenía hijos, marcamos eso con el carácter '@', piénsalo como nuestro carácter EOL.
* Si no, regresamos el valor del nodo y luego agregamos el resultado de serializar sus hijos izquierdo y derecho.

Esto tiene el menor número de líneas, ya que navegar por el árbol es rápido de esta forma y no hay necesidad de revisar muchos casos extremos.

La deserialización usualmente es la parte divertida.

Lo hice preparando primero los nodos, convirtiéndolos en un arreglo (o una List en la versión de Python) y luego usando un iterador para moverme una posición a la vez. ¿Recuerdas cómo hicimos la serialización? Un nodo a la vez evaluamos los nodos izquierdo y derecho, así que el código para la deserialización usa una lógica similar:

* Si el elemento actual es nuestro carácter EOL, sabemos que esto pertenece a una hoja del nodo y debería ser un Node nulo.
* Si no, sabemos que el elemento actual corresponde a un Node, así que lo inicializamos con su valor y luego usamos recursión para evaluar sus nodos Left y Right, moviendo el Iterator una posición a la vez.

¡Ganancia!

Pensé que esto iba a estar más difícil. Creo que la primera vez que vi este problema seguramente me hice bolas con las condiciones y no me di cuenta de que la recursión era el camino. Creo que estaba tratando de llevar la cuenta de las posiciones para saber si estaba evaluando el lado izquierdo o derecho del árbol. Ya ni me acuerdo, pero en cuanto le pensé tantito todo quedó más claro.
Una forma de ver el uso de la recursión es que al agregar una llamada a nuestro call stack, en realidad estamos encolando (los nombres no ayudan mucho, lo sé), lo cual después va a procesar nuestros comandos en el orden en que los pedimos. Los Stacks y las Queues son estructuras de datos tremendamente importantes para trabajar con árboles, así que vale la pena repasarlas.

¡Espero que te haya gustado este post y que te sirva para tus propios estudios! También estoy trabajando en algo un poco diferente, una especie de proyecto personal que quiero publicar, así que vas a ver algo interesante en los próximos posts. ¡Sigue al pendiente!


> Na lû e-govaned 'wîn
</content>
