---
layout: post
title: "Las 5 partes de un buen prompt (y la más fácil de olvidar)"
description: "Las cinco partes de un buen prompt para ChatGPT, Claude o cualquier IA, con ejemplos de antes y después para copiar y la que es más fácil olvidar."
date: 2026-10-04 12:47:15 -0500
categories: quick-starts
section: quick-starts
lang: es
page_id: parts-of-a-good-prompt
permalink: /entradas/guias-rapidas/partes-de-un-buen-prompt/
series: prompts-101
---

Cuando una IA te da una respuesta sosa, revisa tu prompt antes de echarle la culpa. Un buen prompt puede tener cinco partes, y una de ellas es facilísima de olvidar.

Un prompt es lo que le escribes a una app de IA como ChatGPT, Claude, Gemini o Copilot. Estas son sus cinco partes, sin tecnicismos:

- **Tarea:** lo que quieres que haga
- **Contexto:** lo que solo tú sabes
- **Ejemplos:** una muestra de cómo se ve algo bueno
- **Formato:** la forma de la respuesta
- **Rol:** el papel que toma la IA

No siempre necesitas las cinco. Mi regla práctica: la Tarea es la única que todo prompt necesita. Las demás las agregas cuando la respuesta tiene que quedarte a la medida.

Los nombres son mi versión, en palabras de todos los días, de las partes que describe [la guía de estructura de prompts de Learn Prompting](https://learnprompting.org/docs/basics/prompt_structure) (en inglés), donde usan etiquetas más técnicas como "directive" y "output formatting".

## Las cinco partes, con antes y después

**Tarea.** Di exactamente qué quieres.

```text
Antes:
Ayúdame con la cena.

Después:
Dame 5 ideas de cena que pueda cocinar en casa para el cumpleaños 60 de mi mamá.
```

**Contexto.** Lo que solo tú sabes. Más abajo tiene su propia sección, porque es el que se nos escapa.

```text
Antes:
Escríbele un mensaje al dueño del departamento sobre la fuga.

Después:
Escríbele un mensaje al dueño del departamento. El fregadero de la
cocina lleva una semana goteando. Le escribí el lunes y no me ha
contestado. Quiero seguir en buenos términos porque pienso renovar
el contrato en marzo, pero necesito que lo arreglen esta semana.
```

La segunda versión le dice cuánto tiempo lleva el problema y por qué no te conviene pelearte con él.

Y aquí sale un detalle muy nuestro: ¿al dueño le hablas de tú o de usted? Si no lo dices, la IA decide por ti. Agrega "háblale de usted" y listo.

**Ejemplos.** Muéstrale en lugar de describirle.

```text
Antes:
Escribe un mensaje para darle las gracias a mi vecina.

Después:
Escribe un mensaje para darle las gracias a mi vecina por regarme
las plantas. Así suenan mis mensajes:
"¡Eres la mejor! Te debo unos tamales 🙏"
Que suene igual.
```

Anthropic, la empresa detrás de Claude, dice que los ejemplos son "una de las formas más confiables de guiar" cómo se ve y cómo suena la respuesta.

**Formato.** Dile qué forma quieres que tenga.

```text
Antes:
¿Qué tengo que comprar para la cena?

Después:
Hazme la lista del súper como checklist, agrupada por pasillo,
y que quepa en una sola pantalla.
```

Otros pedidos de formato que funcionan bien: "en menos de 100 palabras", "en una tabla", "como mensaje de WhatsApp, sin saludo" y "en pasos numerados".

**Rol.** El papel que quieres que tome la IA.

```text
Antes:
Organiza una fiesta.

Después:
Actúa como un organizador de eventos buena onda y experto en
presupuestos apretados. Organiza una fiesta para [la ocasión].
```

La guía de Anthropic, escrita para desarrolladores, dice que asignar un rol enfoca el comportamiento y el tono de la IA, y que "hasta una sola oración hace la diferencia". El rol le da ángulo y tono a la respuesta. La IA sigue sabiendo exactamente lo mismo que antes, así que revisa sus datos de todos modos.

## Por qué el contexto es el más fácil de olvidar

El contexto es todo lo que solo tú sabes y que la IA necesita para ayudarte bien.

Se nos escapa porque vive en nuestra cabeza. Tú sabes el presupuesto y la fecha límite. La IA solo sabe lo que está en el chat.

Cuando le falta algo, por lo general no se detiene a preguntar. Rellena el hueco con una suposición genérica, y de suposiciones genéricas salen respuestas sosas.

La guía de prompts de Anthropic lo explica así (la traducción es mía):

> "Piensa en Claude como un empleado brillante pero nuevo, que no conoce las normas ni la forma de trabajar de tu equipo. Entre más precisa sea tu explicación de lo que quieres, mejor será el resultado."

Habla de Claude, pero aplica a cualquier app de IA. Un empleado nuevo, por brillante que sea, no puede adivinar tu presupuesto.

Antes de mandar un prompt importante, repasa cinco preguntas:

1. ¿Para quién es?
2. ¿Para qué lo necesito?
3. ¿Cuáles son mis límites? Presupuesto, tiempo, habilidad, extensión.
4. ¿Qué ya intenté o ya decidí?
5. ¿Cómo se vería un resultado excelente?

Atajo: si se lo pidieras a un amigo, ¿qué te preguntaría primero? Pon esas respuestas en el prompt.

Luego haz la prueba que la guía llama su regla de oro:

> "Muéstrale tu prompt a un colega que sepa poco de la tarea y pídele que lo siga. Si a él lo confunde, a Claude también lo va a confundir."

Un truco más de la misma guía: dile a la IA *por qué*. Su ejemplo es "NUNCA uses puntos suspensivos", que funciona peor que explicarle que la respuesta la va a leer en voz alta un programa de texto a voz (software que lee textos en voz alta) que no sabe pronunciarlos. Según la guía, Claude "es lo bastante listo para generalizar a partir de la explicación". La razón también es contexto.

## Pruébalo: misma IA, dos prompts

Abre dos chats nuevos en cualquier app de IA y pega un prompt en cada uno.

```text
Dame ideas para una cena de cumpleaños.
```

```text
Dame 5 ideas de cena para el cumpleaños 60 de mi mamá. Somos 8,
2 son vegetarianos, tengo unos $2,000 pesos y cocino más o menos,
con una tarde para preparar todo.
```

Usa chats nuevos para que la segunda respuesta no se copie de la primera. Si tu app recuerda cosas de ti entre un chat y otro, eso puede mover el resultado.

Corrí los dos en Claude, con Sonnet 5.5, cada uno en su propio chat nuevo. Tenía prendida la memoria de Claude, así que los dos chats podían usar lo que recuerda de mí. Aun así, el prompt corto recibió una respuesta genérica. Aquí está:

![Claude contestando "Dame ideas para una cena de cumpleaños." con opciones generales como carpaccio, salmón, una noche de sushi, fondue o ir a un restaurante, y al final preguntando cuántas personas serán y cuál es el presupuesto](/assets/images/posts/parts-of-a-good-prompt/cumple-antes.png)

Y este es el que lleva contexto:

![Claude, en un chat nuevo, contestando el prompt detallado del cumpleaños 60 con 5 ideas para 8 personas, todas con opción vegetariana, como una taquiza de guisados, pozole rojo y verde y enchiladas suizas, más consejos para que rinda el presupuesto](/assets/images/posts/parts-of-a-good-prompt/cumple-despues.png)

La primera respuesta propone de todo, desde carpaccio y pulpo a la parrilla hasta salir a un restaurante, sin pensar en vegetarianos ni en dinero. Fíjate que primero adivinó. Hasta el final me preguntó cuántas personas serían y cuál era el presupuesto, que es justo el contexto que no le di.

La segunda trabajó con lo que le conté. Sacó la cuenta sola (unos $250 por cabeza) y todas sus ideas traen opción vegetariana. Hasta me sugirió apartar $300 para el pastel.

Y esta es la versión completa con las cinco partes, primero el contexto y al final lo que pides:

```text
Actúa como alguien que cocina rico en casa y sabe estirar el presupuesto.
Es el cumpleaños 60 de mi mamá. Somos 8 personas, 2 son vegetarianas,
tengo unos $2,000 pesos y cocino más o menos, con una tarde para preparar.
A ella le encanta lo casero y no come muy picante.
Este es el tipo de platillo que busco: unas enchiladas suizas que pueda
dejar armadas y meter al horno justo antes de que lleguen.
Dame 5 ideas de cena que pueda cocinar en casa.
Ponlas en una lista corta, con una línea de por qué funciona cada una,
y marca las vegetarianas.
```

Línea por línea: rol, contexto, ejemplo, tarea y formato.

El orden lo sugiere Learn Prompting. Su razón: si lo que pides va al final, es menos probable que la IA nada más se ponga a seguir escribiendo tu contexto. En prompts cortos del día a día, cualquier orden claro funciona. Tómalo como un hábito práctico. Si escribes primero lo que pides, no pasa nada.

## Tu guía rápida

| Parte | Qué es | Pregúntate |
|---|---|---|
| Tarea | Lo que quieres que haga | ¿Qué quiero exactamente? |
| Contexto | Lo que solo tú sabes | ¿Qué necesitaría saber un amigo? |
| Ejemplos | Cómo se ve algo bueno | ¿Puedo mostrar uno? |
| Formato | La forma de la respuesta | ¿Lista, tabla, texto corto? ¿Qué tan largo? |
| Rol | El papel que toma la IA | ¿Quién sería ideal para ayudarme? |

Cuántas partes usar:

- Un dato rápido ("¿Cuántas tazas tiene un litro?"): solo la Tarea.
- Ayuda del día a día, como mensajes y planes: Tarea más Contexto.
- Algo con un estilo o una forma específica: agrega Ejemplos y Formato.
- Rol: un toque opcional.

Entre más personal quieras el resultado, más partes le agregas.

Esta es la parte 1 de una serie para principiantes. Cada parte va a tener su propia entrada, empezando por el contexto. Más adelante: lo que la IA recuerda dentro de un chat y cuándo conviene empezar uno nuevo.

Fuentes (en inglés): [las buenas prácticas de prompts de Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) y [la guía de estructura de prompts de Learn Prompting](https://learnprompting.org/docs/basics/prompt_structure).

Tu siguiente paso: abre el último chat donde te dieron una respuesta genérica, agrega el contexto que te faltó y vuelve a preguntar.
