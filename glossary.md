# Howstr Glossary
Start with these terms:
- [state](#state)
- [change](#change)
- [step](#step)

##change
A type of [node](##node)
Changes are an important part of the [sequence](##sequence) dimension.

##node
A [state](##state) or a [change](##change)
Generally looks like a shape on the graph, usually a rectangle.

##link
A type of [step](##step)
A [bond](##bond), [flow](##flow), [dive](##dive), or [rise](##rise)
Generally looks like one or more arrows on the graph.

##NotionAll

##sequence
A type of [dimension](##dimension)

##state
A type of [node](##node)
States are an important part of the [sequence](##sequence) dimension. They are like a noun. They are assumed to represent a description of a thing that is true at some instant in time. It is possible for states to cover a span of time provided the entire description is true for the entire span of time (like if something sits unchanged in storage).
All of the information attached to a state must be true simultaneously and must not leave out any details necessary to distinguish one state from another.

g
g
g
g
g
g
g
g
g
g
g
g
g
g

##step
A [node](##node) or a [link](##link)
Steps are actually the same thing in the underlying [NotionAll](##NotionAll) array. Howstr creates a node or a link by attaching an appropriate tag to a record. Howstr's algorithms treat nodes and links differently.