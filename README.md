# -VC:MP-Snippet - 1


# **Include Function**
- JavaScript has a convenient .includes function, but unfortunately, it's not available in Squirrel. This can be frustrating when you need to repeatedly loop over an array to check for a specific value. That's why I took the initiative to create a simple "include" function specifically for VC:MP.

## The Use
- It has simple syntax, **include(arrayName, var)**

### Example:
```local fruits = ["mango", "banana", "watermelon"];```

```print(includes(fruits, "mango")) //returns true if the item is in variable else false.```

---

# -VC:MP-Snippet - 2

# Text Filter Function:
- Prevents abusive language and toxic behavior by automatically filtering and replacing offensive words with asterisks.
- Say goodbye to offensive language and enjoy a more enjoyable gaming experience.
- Let's create a fun and inclusive vcmp community together! <3

# -VC:MP-System - 1

# Property System
- Available commands: (/) addprop, delprop, buyprop, sellprop, shareprop, delshareprop, myprops, sharedprops.
- The /delprop command is buggy and that's why it is commented.. actually the ID (primary_key) starts from 1 whereas pickupID's start from 0 and that's what is causing the bug.
- I don't have much time to fix it, but if you want; you can fix it by removing the primaryKey keyword from ID and saving it like any other data.
