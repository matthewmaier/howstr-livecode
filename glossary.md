# Howstr Glossary
Start with these terms:
- [state](#state)
- [change](#change)
- [step](#step)

##action
A [change](#change) and all of the [states](#state) linked to it.
States can be part of more than one action, but an action is defined by the one change it's centered around.

##bond
A type of [link](#link)
Bonds have no direction and ignore the [scope](#scope) and [sequence](#sequence) dimensions. They are interpreted, or ignored, on a case-by-case basis in each Howstr algorithm. For example, in the instructions view (topological sort) bond links are treated like footnotes. 

##change
A type of [node](#node)
Generally represented by a triangle (like a delta)
Changes are an important part of the [sequence](##sequence) dimension. They are like verbs. Howstr assumes they represent something that happens over a span of time that converts the world from one state to another. It is possible for changes to only take an instant provided something is different at the beginning and end of that instant.
The information attached to a change must not include the definition(s) of any states, since that information should be recorded in the states themselves.

##demand 

##dimension
The dimensions Howstr uses are [history](#history), [scope](#scope), and [sequence](#sequence)
These aren't really literal dimensions. What this characterization means is that a single node can be relevant in different perspectives at the same time. Altering the information for one perspective doesn't necessarily have any effect on the other perspectives. For example, fixing a typo alters the history perspective, but nothing else.

##dive
A type of [link](#link) in the [scope](#scope) [dimension](#dimension)
Think of it as "diving" inside of a case to see the encased details. This directional link goes from the encasing node to an input node in the encased [flow](#flow). This link is how Howstr knows what is supposed to be encased and therefore affects calculations.
A dive link must be paired with at least one [rise](#rise) link to complete the loop, and that rise link must appear later in the encased flow.

##flow
The [link](#link) in the [sequence](#sequence) [dimension](#dimension)
This directional link specifies that one thing comes before/after another. Flow links do not technically create a timeline, but the sequence they describe can cover a period of time.

##history
A type of [dimension](#dimension)
This dimension comes from the [NotionAll](#NotionAll) specification. Howstr uses it in several important ways. It allows for an infinite undo/redo stack. It also allows authors to include each other's work without worrying about the thing they linked to changing in the future. This dimension also allows Howstr to find resources even if their location or filename changes.

##input

##link
A type of [step](#step)
A [bond](#bond), [flow](#flow), [dive](#dive), or [rise](#rise)
Generally looks like one or more arrows on the graph. One link connects one node to one other node.

##node
A [state](#state) or a [change](#change)
Generally looks like a shape on the graph, usually a rectangle.

##NotionAll
A standard for building an array. ! link to NotionAll repository
The NotionAll standard can be used to build an augmented adjacency list. Any number of different dimensions of information can be captured by attaching appropriate key:value pairs to each record in the array. Information is only ever added to a NotionAll array, never deleted, so the state of the array at any point in the past can be recreated while only recording the information once.
Howstr uses the NotionAll standard to organize the information that humans need to understand how to do things.

##output

##rise
A type of [link](#link) in the [scope](#scope) [dimension](#dimension)
Think of it as "rising" up out of the encased details. This directional link goes from an [output](#output) state in the encased [flow](#flow) to the encasing [state](#state).
A rise link must be paired with at least one [dive](#dive) link to complete the loop, and that dive link must appear earlier in the encased flow.

##scope
A type of [dimension](#dimension)
This is like a work breakdown structure (WBS) in project management where a big job (build house) is broken down into smaller and smaller tasks (lay foundation > mix cement > open bag). 
Anything "higher" in the scope dimension is a summary of the "lower" things it encases. The summary is a combination of information calculated automatically by Howstr or attached manually.
Scope is created with [dive](#dive) and [rise](#rise) links "under" a case state. What is encased is a [flow](#flow) of [actions](#action). The first state(s) is an [input](#input) and the last state(s) is an [output](#output). The dive links go from the case state to an input state and rise links go from an output state back to the case state. This creates a closed loop dive > flow > rise.

##sequence
A type of [dimension](#dimension)
The sequence means that one step logically comes after/before another. Like a precedence diagram in project management.
Defined by [flow](#flow) links between [steps](#step).
Started by [input](#input) [states](#state), filled with [thruput](#thruput) states & [changes](#change), and ended by [output)(#output) states. Encased by [dive](#dive) and [rise](#rise) links.

##state
A type of [node](#node)
Generally represented by a square (like a polaroid)
States are an important part of the [sequence](#sequence) dimension. They are like a noun. Howstr assumes they represent a description of a thing that is true at some instant in time. It is possible for states to cover a span of time provided the entire description is true for the entire span of time (like if something sits unchanged in storage).
All of the information attached to a state must be true simultaneously and must not leave out any details necessary to distinguish one state from another.

##step
A [node](#node) or a [link](#link)
Steps are actually the same thing in the underlying [NotionAll](#NotionAll) array. Howstr creates a node or a link by attaching an appropriate tag to a record. Howstr's algorithms treat nodes and links differently.
It is possible to attach any kind of information to a step by creating a tag and putting data in it. Anything Howstr doesn't recognize will just be displayed and if it can't be displayed it will simply be stored.

##supply

##thruput
A step in the [sequence](#sequence) dimension that is not an [input](#input) or an [output](#output).
Howstr usually won't report anything about a thruput, but an important exception is when there's an imbalance between [supply](#supply) and [demand](#demand).