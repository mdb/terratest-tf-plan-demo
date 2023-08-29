# VHS documentation
#
# Output:
#   Output <path>.gif               Create a GIF output at the given <path>
#   Output <path>.mp4               Create an MP4 output at the given <path>
#   Output <path>.webm              Create a WebM output at the given <path>
#
# Settings:
#   Set FontSize <number>           Set the font size of the terminal
#   Set FontFamily <string>         Set the font family of the terminal
#   Set Height <number>             Set the height of the terminal
#   Set Width <number>              Set the width of the terminal
#   Set LetterSpacing <float>       Set the font letter spacing (tracking)
#   Set LineHeight <float>          Set the font line height
#   Set Theme <string>              Set the theme of the terminal (JSON)
#   Set Padding <number>            Set the padding of the terminal
#   Set Framerate <number>          Set the framerate of the recording
#   Set PlaybackSpeed <float>       Set the playback speed of the recording
#
# Sleep:
#   Sleep <time>                    Sleep for a set amount of <time> in seconds
#
# Type:
#   Type[@<time>] "<characters>"    Type <characters> into the terminal with a
#                                   <time> delay between each character
#
# Keys:
#   Backspace[@<time>] [number]     Press the Backspace key
#   Down[@<time>] [number]          Press the Down key
#   Enter[@<time>] [number]         Press the Enter key
#   Space[@<time>] [number]         Press the Space key
#   Tab[@<time>] [number]           Press the Tab key
#   Left[@<time>] [number]          Press the Left Arrow key
#   Right[@<time>] [number]         Press the Right Arrow key
#   Up[@<time>] [number]            Press the Up Arrow key
#   Down[@<time>] [number]          Press the Down Arrow key
#   Ctrl+<key>                      Press the Control key + <key> (e.g. Ctrl+C)
#
# Display:
#   Hide                            Hide the subsequent commands from the output
#   Show                            Show the subsequent commands in the output

Output demo.gif

Set FontSize 18
Set LineHeight 1.3
Set Width 1800
Set Height 800

# Step
Type 'echo "Run terraform plan against the configuration..."'
Enter
Sleep 8s
Enter
Enter

Type 'make plan'
Sleep 8s
Enter

Sleep 10s

# Step
Enter
Enter
Type 'echo "Save the plan to out.json..."'
Enter
Sleep 8s
Enter
Enter

Type 'make show'
Sleep 8s
Enter

Sleep 10s

# Step
Enter
Enter
Type 'echo "Test the plan using terratest."'
Enter
Sleep 8s
Type 'echo "Note the tests pass..."'
Enter
Sleep 8s
Enter
Enter

Type 'make test'
Sleep 8s
Enter

Sleep 10s

# Step
Enter
Enter
Type 'echo "Introduce a change to the Terraform configuration..."'
Enter
Sleep 8s
Enter
Enter

Type 'sed -i "" "s/foo/foo_new_name/g" main.tf'
Sleep 8s
Enter

Sleep 10s

Type 'git --no-pager diff'
Sleep 8s
Enter

Sleep 10s

# Step
Enter
Enter
Type 'echo "Run terraform plan..."'
Enter
Sleep 8s
Enter
Enter

Type 'make plan'
Sleep 8s
Enter

Sleep 10s

# Step
Enter
Enter
Type 'echo "Save the plan to out.json..."'
Enter
Sleep 8s
Enter
Enter

Type 'make show'
Sleep 8s
Enter

Sleep 10s

# Step
Enter
Enter
Type 'echo "Test the plan using terratest."'
Enter
Sleep 8s
Type 'echo "Note the tests fail, as the plan includes a destructive action against an existing resource..."'
Enter
Sleep 8s
Enter
Enter

Type 'make test'
Sleep 8s
Enter

Sleep 10s

# Step
Enter
Enter
Type 'echo "Undo the change..."'
Enter
Sleep 8s
Enter
Enter

Type 'git checkout .'
Sleep 8s
Enter

# Step
Enter
Enter
Type 'echo "Introduce another change to the Terraform configuration..."'
Enter
Sleep 8s
Enter
Enter

Type 'echo "resource \"null_resource\" \"foo_new\" {}" >> main.tf'
Enter
Sleep 10s

Type 'git --no-pager diff'
Sleep 8s
Enter

Sleep 10s

# Step
Enter
Enter
Type 'echo "Run terraform plan..."'
Enter
Sleep 8s
Enter
Enter

Type 'make plan'
Sleep 8s
Enter

Sleep 10s

# Step
Enter
Enter
Type 'echo "Save the plan to out.json..."'
Enter
Sleep 8s
Enter
Enter

Type 'make show'
Sleep 8s
Enter

Sleep 10s

# Step
Enter
Enter
Type 'echo "Test the plan using terratest."'
Enter
Sleep 8s
Type 'echo "Note the tests pass, as the plan includes no destructive actions..."'
Enter
Sleep 8s
Enter
Enter

Type 'make test'
Sleep 8s
Enter

Sleep 28s
