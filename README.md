Notes:  
  
Commands:  
Done:
(label X) // X is label (you cannot call a label 'main')  
(goto X) // X is label  
(pause)  
(changeBg X) // X is new bg file  
(decision (P) rest...)  
P is prompt String, rest are choices in the format:  
(Entry)(COMMAND)  
Example: (decicion (Do you go outside?) (Yes)(yesLabel) (No)(noLabel))  

ToDo:
(// X) // X is the comment  
(clear)  
(fadeIn)  
(fadeOut)  
(speaking X) // X is character  
  
(changeSong X) // X is new song file  
(playSound X) // X is sound file  
(forcePause X) // X is seconds  
