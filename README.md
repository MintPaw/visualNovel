Notes:

	Commands:
	Done:
	label X // X is label (you cannot call a label 'main')
	goto(X) // X is label
	pause()
	changeBg(X) // X is new bg file

	decision(X, C)

	X is prompt String, C is an array of choices in the format:
	"Option Text", "codeToRun()"
	Example:
	decision(
		"Do you go outside?",
		["Yes", "goto('yesLabel')",
		"No", "goto('noLabel')")

	speaking(X) // X is character
	clear()
	fadeOut(X) // X is colour in hex
	fadeIn()
	wait(X) // X is milliseconds

	Todo:
	changeSong(X) // X is new song file
	playSound(X) // X is sound file
