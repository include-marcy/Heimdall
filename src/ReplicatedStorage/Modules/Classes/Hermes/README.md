![Hermes Text Logo Dark](../../../../../assets/HermesTextLogo.png)
# What is Hermes?
Hermes is a Roblox Parallel Luau Library and API (Application Program Interface) designed solely for Roblox Studio and its associated software. Hermes simplifies and organizes the process of utilizing Parallel Luau in your projects, reducing overhead complexity associated with standard implementations of the parallel API.

# Overview of the Hermes API
Hermes main goal is speed. Performance is a critical priority of Roblox developers, and Hermes was built with this need in mind. But, it is important to understand that not all tasks are supposed to be ran in parallel. Carefully consider when you might need the overhead associated with parallel computing, because there is a non-zero cost to implementing parallel computation to your program. 
Any application serving physics, complex computations, rigid and long mathematics, mesh editing, or image editing should strongly consider Hermes as a supporting or primary library for their applications. Hermes has a robust and powerful API with an explicit OOP design. Hermes is written in, and implemented entirely in Luau.