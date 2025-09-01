
param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [string]$Theme = $DEFAULT_PDF_THEME,
    [string]$ExtraArgs = "",
    [switch]$Optimize = $false
)

function FixWslPath([string]$fileDir)
{
    $wslFileDir = $fileDir -replace "\\", "/"

    if ($wslFileDir -match "^([A-Za-z]):")
    {
        $drive = $matches[1].toLower()
        $wslFileDir = $wslFileDir -replace "^([A-Za-z]):", "/mnt/$drive"
    }
    $wslFileDir
}

$file = Get-Item $Path
[string]$baseName = if ($file.Extension.Length -gt 0)
{
    $file.FullName.Remove($file.FullName.Length - $file.Extension.Length)
} else
{
    $file.FullName
}


if ($file.Extension -eq ".md")
{
    convertto-asciidoc $Path
    $Path = "${baseName}.adoc"
}

[string]$fileDir = [System.IO.Path]::GetDirectoryName($baseName)
[string]$fileName = [System.IO.Path]::GetFileNameWithoutExtension($Path)

$wslFileDir = FixWslPath $fileDir
$wslThemeDir = FixWslPath $PDF_THEMES_DIR

write-host $wslFileDir $wslThemeDir

docker run --rm `
    -v "${wslThemeDir}:/themes" `
    -v "${wslFileDir}:/docs" `
    asciidoctor-pdf `
    "/docs/$fileName.adoc"

if ($Optimize)
{
    qpdf "${baseName}.pdf" --linearize "${baseName}-out.pdf"
}
