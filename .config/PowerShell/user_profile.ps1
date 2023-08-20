# Parallel Loading ------------------------------------------------------------------------

# $IconsShell = Start-ThreadJob {
# 	Import-Module Terminal-Icons
# }

# $Fzf = Start-ThreadJob {
# 	Import-Module PSFzf
# 	Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
# }

# $Starship = Start-ThreadJob {
# 	Invoke-Expression (&starship init powershell)
# }

# $Chocolatey = Start-ThreadJob {
# 	$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
# 	if (Test-Path($ChocolateyProfile)) {
# 	  Import-Module "$ChocolateyProfile"
# 	}
# }


# PSReadLine ------------------------------------------------------------------------------

Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
#Set-PSReadLineOption -PredictionViewStyle ListView

# Prompt ----------------------------------------------------------------------------------

Import-Module Terminal-Icons
Invoke-Expression (&starship init powershell)

# Fzf -------------------------------------------------------------------------------------

Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Chocolatey ------------------------------------------------------------------------------

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
#  Import-Module "$ChocolateyProfile"
}

# z ---------------------------------------------------------------------------------------

Import-Module z

# User Defined ----------------------------------------------------------------------------

function rconf() {
	subl (rclone config file | grep conf)
}

function lnsync([string]$param) {
	if ($param) {
		Write-Output "rclone sync `"D:/ln/`" `"server:/LN/`" -n"
		rclone sync "D:/ln/" "server:/LN/" -n
	}
	else {
		Write-Output "rclone sync `"D:/ln/`" `"server:/LN/`" -P"
		rclone sync "D:/ln/" "server:/LN/" -P
	}
}

function pwshistory() {
	subl (Get-PSReadLineOption).HistorySavePath
}

function hists() {
	cat (Get-PSReadLineOption).HistorySavePath | fzf
}

function newvenv([string]$Param) {
	if ($Param) {
		if (!(Test-Path $PWD\$Param)) {
			virtualenv $Param
		}
		else {
			Write-Output "Already Exists"
		}
	}
	else {
		if (!(Test-Path $PWD\venv)) {
			virtualenv .venv
		}
		else {
			Write-Output "Already Exists"
		}
	}
}

function adld() {
	$pdir = $PWD.Path
	cd D:/projects/gsearch/gsearch
	../.venv/Scripts/activate
	Invoke-Expression "python main.py"
	deactivate
	cd $pdir
}

function tunnel() {
	cd C:/Software/Powertunnel
	java -jar PowerTunnel.jar --start --minimized
}

function cleanhist() {
	$pdir = $PWD.Path
	cd C:\Users\manas\.config\PowerShell
	python clean_history.py $(Get-PSReadLineOption).HistorySavePath
	cd $pdir
}

function Remove-DuplicateHistory {
    $historyFilePath = $(Get-PSReadLineOption).HistorySavePath
    $lines = Get-Content -Path $historyFilePath | Select-Object -Unique
    $lines | Set-Content -Path $historyFilePath
}

function lcstats() {
    python D:\scripts\lcstats\lcstats.py
}

function poweroff() {
	shutdown /s /t 0
}

function reboot() {
	shutdown /r /t 0
}

function hibernate() {
	shutdown /h
}

# Wait for Parallel Jobs -----------------------------------------------------------------

# Receive-Job $IconsShell -Wait -AutoRemoveJob
# Receive-Job $Fzf -Wait -AutoRemoveJob
# Receive-Job $Starship -Wait -AutoRemoveJob
# Receive-Job $Chocolatey -Wait -AutoRemoveJob
# powershell completion for rclone                               -*- shell-script -*-

function __rclone_debug {
    if ($env:BASH_COMP_DEBUG_FILE) {
        "$args" | Out-File -Append -FilePath "$env:BASH_COMP_DEBUG_FILE"
    }
}

filter __rclone_escapeStringWithSpecialChars {
    $_ -replace '\s|#|@|\$|;|,|''|\{|\}|\(|\)|"|`|\||<|>|&','`$&'
}

[scriptblock]$__rcloneCompleterBlock = {
    param(
            $WordToComplete,
            $CommandAst,
            $CursorPosition
        )

    # Get the current command line and convert into a string
    $Command = $CommandAst.CommandElements
    $Command = "$Command"

    __rclone_debug ""
    __rclone_debug "========= starting completion logic =========="
    __rclone_debug "WordToComplete: $WordToComplete Command: $Command CursorPosition: $CursorPosition"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $CursorPosition location, so we need
    # to truncate the command-line ($Command) up to the $CursorPosition location.
    # Make sure the $Command is longer then the $CursorPosition before we truncate.
    # This happens because the $Command does not include the last space.
    if ($Command.Length -gt $CursorPosition) {
        $Command=$Command.Substring(0,$CursorPosition)
    }
    __rclone_debug "Truncated command: $Command"

    $ShellCompDirectiveError=1
    $ShellCompDirectiveNoSpace=2
    $ShellCompDirectiveNoFileComp=4
    $ShellCompDirectiveFilterFileExt=8
    $ShellCompDirectiveFilterDirs=16

    # Prepare the command to request completions for the program.
    # Split the command at the first space to separate the program and arguments.
    $Program,$Arguments = $Command.Split(" ",2)

    $RequestComp="$Program __complete $Arguments"
    __rclone_debug "RequestComp: $RequestComp"

    # we cannot use $WordToComplete because it
    # has the wrong values if the cursor was moved
    # so use the last argument
    if ($WordToComplete -ne "" ) {
        $WordToComplete = $Arguments.Split(" ")[-1]
    }
    __rclone_debug "New WordToComplete: $WordToComplete"


    # Check for flag with equal sign
    $IsEqualFlag = ($WordToComplete -Like "--*=*" )
    if ( $IsEqualFlag ) {
        __rclone_debug "Completing equal sign flag"
        # Remove the flag part
        $Flag,$WordToComplete = $WordToComplete.Split("=",2)
    }

    if ( $WordToComplete -eq "" -And ( -Not $IsEqualFlag )) {
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __rclone_debug "Adding extra empty parameter"
        # We need to use `"`" to pass an empty argument a "" or '' does not work!!!
        $RequestComp="$RequestComp" + ' `"`"'
    }

    __rclone_debug "Calling $RequestComp"
    # First disable ActiveHelp which is not supported for Powershell
    $env:RCLONE_ACTIVE_HELP=0

    #call the command store the output in $out and redirect stderr and stdout to null
    # $Out is an array contains each line per element
    Invoke-Expression -OutVariable out "$RequestComp" 2>&1 | Out-Null

    # get directive from last line
    [int]$Directive = $Out[-1].TrimStart(':')
    if ($Directive -eq "") {
        # There is no directive specified
        $Directive = 0
    }
    __rclone_debug "The completion directive is: $Directive"

    # remove directive (last element) from out
    $Out = $Out | Where-Object { $_ -ne $Out[-1] }
    __rclone_debug "The completions are: $Out"

    if (($Directive -band $ShellCompDirectiveError) -ne 0 ) {
        # Error code.  No completion.
        __rclone_debug "Received error from custom completion go code"
        return
    }

    $Longest = 0
    $Values = $Out | ForEach-Object {
        #Split the output in name and description
        $Name, $Description = $_.Split("`t",2)
        __rclone_debug "Name: $Name Description: $Description"

        # Look for the longest completion so that we can format things nicely
        if ($Longest -lt $Name.Length) {
            $Longest = $Name.Length
        }

        # Set the description to a one space string if there is none set.
        # This is needed because the CompletionResult does not accept an empty string as argument
        if (-Not $Description) {
            $Description = " "
        }
        @{Name="$Name";Description="$Description"}
    }


    $Space = " "
    if (($Directive -band $ShellCompDirectiveNoSpace) -ne 0 ) {
        # remove the space here
        __rclone_debug "ShellCompDirectiveNoSpace is called"
        $Space = ""
    }

    if ((($Directive -band $ShellCompDirectiveFilterFileExt) -ne 0 ) -or
       (($Directive -band $ShellCompDirectiveFilterDirs) -ne 0 ))  {
        __rclone_debug "ShellCompDirectiveFilterFileExt ShellCompDirectiveFilterDirs are not supported"

        # return here to prevent the completion of the extensions
        return
    }

    $Values = $Values | Where-Object {
        # filter the result
        $_.Name -like "$WordToComplete*"

        # Join the flag back if we have an equal sign flag
        if ( $IsEqualFlag ) {
            __rclone_debug "Join the equal sign flag back to the completion value"
            $_.Name = $Flag + "=" + $_.Name
        }
    }

    if (($Directive -band $ShellCompDirectiveNoFileComp) -ne 0 ) {
        __rclone_debug "ShellCompDirectiveNoFileComp is called"

        if ($Values.Length -eq 0) {
            # Just print an empty string here so the
            # shell does not start to complete paths.
            # We cannot use CompletionResult here because
            # it does not accept an empty string as argument.
            ""
            return
        }
    }

    # Get the current mode
    $Mode = (Get-PSReadLineKeyHandler | Where-Object {$_.Key -eq "Tab" }).Function
    __rclone_debug "Mode: $Mode"

    $Values | ForEach-Object {

        # store temporary because switch will overwrite $_
        $comp = $_

        # PowerShell supports three different completion modes
        # - TabCompleteNext (default windows style - on each key press the next option is displayed)
        # - Complete (works like bash)
        # - MenuComplete (works like zsh)
        # You set the mode with Set-PSReadLineKeyHandler -Key Tab -Function <mode>

        # CompletionResult Arguments:
        # 1) CompletionText text to be used as the auto completion result
        # 2) ListItemText   text to be displayed in the suggestion list
        # 3) ResultType     type of completion result
        # 4) ToolTip        text for the tooltip with details about the object

        switch ($Mode) {

            # bash like
            "Complete" {

                if ($Values.Length -eq 1) {
                    __rclone_debug "Only one completion left"

                    # insert space after value
                    [System.Management.Automation.CompletionResult]::new($($comp.Name | __rclone_escapeStringWithSpecialChars) + $Space, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")

                } else {
                    # Add the proper number of spaces to align the descriptions
                    while($comp.Name.Length -lt $Longest) {
                        $comp.Name = $comp.Name + " "
                    }

                    # Check for empty description and only add parentheses if needed
                    if ($($comp.Description) -eq " " ) {
                        $Description = ""
                    } else {
                        $Description = "  ($($comp.Description))"
                    }

                    [System.Management.Automation.CompletionResult]::new("$($comp.Name)$Description", "$($comp.Name)$Description", 'ParameterValue', "$($comp.Description)")
                }
             }

            # zsh like
            "MenuComplete" {
                # insert space after value
                # MenuComplete will automatically show the ToolTip of
                # the highlighted value at the bottom of the suggestions.
                [System.Management.Automation.CompletionResult]::new($($comp.Name | __rclone_escapeStringWithSpecialChars) + $Space, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
            }

            # TabCompleteNext and in case we get something unknown
            Default {
                # Like MenuComplete but we don't want to add a space here because
                # the user need to press space anyway to get the completion.
                # Description will not be shown because that's not possible with TabCompleteNext
                [System.Management.Automation.CompletionResult]::new($($comp.Name | __rclone_escapeStringWithSpecialChars), "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
            }
        }

    }
}

Register-ArgumentCompleter -CommandName 'rclone' -ScriptBlock $__rcloneCompleterBlock

# --------------------------------

# fnm env vars
fnm env --use-on-cd | Out-String | Invoke-Expression

