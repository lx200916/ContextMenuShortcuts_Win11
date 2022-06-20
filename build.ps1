function Get-Escaped {
        param (
        $WordParam
    )
    if ($WordParam -eq $null) {
        return ""
    }
    return $WordParam.replace('\','\\').replace('"','\"')
}

$settings=(Get-Content .\settings.json)|ConvertFrom-Json
$icon = Get-Escaped -WordParam $settings.icon
$title = Get-Escaped -WordParam $settings.title
$cmd = Get-Escaped -WordParam $settings.cmd
$uuid = [System.Guid]::NewGuid().toString().toUpper()
$name = $settings.name
# Write-Output $cmd $title $icon
(Get-Content .\ContextMenuDLL\DLLMain.cpp).Replace("@@TITLE@@",$title).Replace("@@ICON@@",$icon).Replace("@@CMD@@",$cmd).Replace("@@UUID@@",$uuid) | Out-File -Encoding utf8 .\Release\ContextMenu.cpp -Force
(Get-Content .\template\AppxManifest.xml).Replace("@@NAME@@",$name).Replace("@@UUID@@",$uuid).Replace("@@TITLE@@",$title) | Out-File -Encoding utf8 .\Release\sparse-pkg\AppxManifest.xml -Force
Invoke-WebRequest https://www.nuget.org/api/v2/package/Microsoft.Windows.ImplementationLibrary/1.0.201120.3 -OutFile Release\wil.zip; Expand-Archive -Force -LiteralPath Release\wil.zip Release\WilUnzipped; Copy-Item -Force -r "Release\WilUnzipped\include\wil" Release
# Begin Compile
cl.exe /c /Zi /nologo /W3 /WX- /diagnostics:column /sdl /Oi /GL /O2 /Oy- /D WIN32 /D NDEBUG /D _WINDOWS /D _USRDLL /D _WINDLL /D _UNICODE /D UNICODE /Gm- /EHsc /MD /GS /Gy /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /permissive- /Fp"Release\ContextMenu.pch" /Fo"Release\\" /Fd"Release\vc142.pdb" /external:W3 /Gd /TP /analyze- /FC /errorReport:queue "Release\ContextMenu.cpp"
link.exe /ERRORREPORT:QUEUE /OUT:"Release\ContextMenu.dll" /INCREMENTAL:NO /NOLOGO runtimeobject.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib shlwapi.lib /DEF:"Release\Source.def" /MANIFEST /MANIFESTUAC:NO /manifest:embed /PDB:"Release\ContextMenu.pdb" /SUBSYSTEM:WINDOWS /OPT:REF /OPT:ICF /LTCG:incremental /LTCGOUT:"Release\ContextMenu.iobj" /TLBID:1 /DYNAMICBASE /NXCOMPAT /IMPLIB:"Release\ContextMenu.lib" /MACHINE:%ARCH% /DLL "Release\ContextMenu.obj"
MakeAppx.exe pack /d "Release\\sparse-pkg\\" /p "Release\apex-sparse.appx" /nv
SignTool.exe sign /fd SHA256 /a /f "Release\Key.pfx" "Release\apex-sparse.appx"