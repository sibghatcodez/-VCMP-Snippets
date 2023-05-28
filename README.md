# -VC:MP-Snippet - 1


# **Include Function**
- JavaScript has a convenient .includes function, but unfortunately, it's not available in Squirrel. This can be frustrating when you need to repeatedly loop over an array to check for a specific value. That's why I took the initiative to create a simple "include" function specifically for VC:MP.

## The Use
- It has simple syntax, include(arrayName, var)

### Example:
```local fruits = ["mango", "banana", "watermelon"];
print(includes(fruits, "mango")) //returns true if the item is in variable else false.```
```
---

# -VC:MP-Snippet - 2

# Text Filter Function:
- Prevents abusive language and toxic behavior by automatically filtering and replacing offensive words with asterisks.
- Say goodbye to offensive language and enjoy a more enjoyable gaming experience.
- Let's create a fun and inclusive vcmp community together! <3
