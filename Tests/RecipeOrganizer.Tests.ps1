$ScriptPath = Join-Path $PSScriptRoot "..\Organize-Recipes.ps1"
$TestDrive = "TestDrive:\"

Describe "Recipe Organizer" {
    Context "Script Loading" {
        It "Should exist" {
            $ScriptPath | Should Exist
        }

        It "Should define Invoke-OrganizeRecipes when dot-sourced" {
            . $ScriptPath
            Get-Command "Invoke-OrganizeRecipes" -ErrorAction SilentlyContinue | Should Not BeNullOrEmpty
        }
    }

    Context "Functionality" {
        BeforeAll {
            . $ScriptPath
            # Create Mock Files
            New-Item -Path "$TestDrive\Recipe.txt" -Value "Ingredients: Flour" -Force | Out-Null
            New-Item -Path "$TestDrive\NotRecipe.txt" -Value "Just a note" -Force | Out-Null
            New-Item -Path "$TestDrive\Dest" -ItemType Directory -Force | Out-Null
        }

        It "Should identify a recipe file" {
            $result = Test-IsRecipe -Content "Ingredients: Flour" -Filename "Recipe.txt"
            $result | Should Be $true
        }

        It "Should ignore a non-recipe file" {
            $result = Test-IsRecipe -Content "Just a note" -Filename "NotRecipe.txt"
            $result | Should Be $false
        }

        It "Should organize files in Test mode" {
            # Capture output to verify logic
            Invoke-OrganizeRecipes -SourcePath $TestDrive -DestinationPath "$TestDrive\Dest" -Mode Test -NoRecurse
            # Since Test mode just writes to host, we assume success if no error is thrown here.
            # Real verification would need mocking Write-Log or checking side effects if not in Test mode.
        }
        
        It "Should copy files in Copy mode" {
            Invoke-OrganizeRecipes -SourcePath $TestDrive -DestinationPath "$TestDrive\Dest" -Mode Copy -NoRecurse
            
            # "Recipe.txt" starts with R, so it should be in Dest/R/Recipe.txt
            $expectedPath = "$TestDrive\Dest\R\Recipe.txt"
            Test-Path $expectedPath | Should Be $true
        }
    }
}
