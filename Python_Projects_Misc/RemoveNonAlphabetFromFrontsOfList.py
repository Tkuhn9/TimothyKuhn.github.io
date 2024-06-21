#! Python3
#Removes numbers/non-letters from the fronts of a list of words

import sys

print("Enter list. Type \"Ctrl + Z\" then \"Enter\" when finished.")
my_list = sys.stdin.readlines()

print("original list: ")
print(my_list)

def fix_list(word):
    if(not word[0].isalpha()):
        #print("Not")
        i = 0
        for letter in word:
            # print(letter)
            if(letter.isalpha()):
                #print("return! " + word[i:])
                return word[i:]
            i = i + 1
            #print("i = " + str(i))
        return ""
    #print("Is")
    return word 

print("\nFixed list=\n")

fixed = list(map(fix_list, my_list))

for item in fixed:
    print(item)