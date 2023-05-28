function includes(arr, value)
 {
  if (typeof arr == "array") {
    for (local i = 0; i < arr.len(); i++) {
      if (arr[i] == value) {
        return true;
      }
    }
  } else if (typeof arr == "string") {
    for (local i = 0; i < arr.len(); i++) {
      if (arr[i] == value) {
        return true;
      }
    }
  } else {
    print("Error: parameter 1 has invalid type 'integer' : expected 'array'");
  }
  
  return false;
}

////USE\\\

local result = includes(["hello", "world!"], "world!");
print(result) //true
