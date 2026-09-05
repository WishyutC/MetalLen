Add-Type -AssemblyName System.Drawing

$sourcePath = Join-Path $PSScriptRoot '..\assets\branding\metallens_icon_master.png'
$source = [System.Drawing.Image]::FromFile($sourcePath)

$icons = [ordered]@{
    'android\app\src\main\res\mipmap-mdpi\ic_launcher.png' = 48
    'android\app\src\main\res\mipmap-hdpi\ic_launcher.png' = 72
    'android\app\src\main\res\mipmap-xhdpi\ic_launcher.png' = 96
    'android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png' = 144
    'android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png' = 192
    'android\app\src\main\res\mipmap-mdpi\ic_launcher_foreground.png' = 108
    'android\app\src\main\res\mipmap-hdpi\ic_launcher_foreground.png' = 162
    'android\app\src\main\res\mipmap-xhdpi\ic_launcher_foreground.png' = 216
    'android\app\src\main\res\mipmap-xxhdpi\ic_launcher_foreground.png' = 324
    'android\app\src\main\res\mipmap-xxxhdpi\ic_launcher_foreground.png' = 432
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@1x.png' = 20
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@2x.png' = 40
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@3x.png' = 60
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@1x.png' = 29
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@2x.png' = 58
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@3x.png' = 87
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@1x.png' = 40
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@2x.png' = 80
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@3x.png' = 120
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@2x.png' = 120
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@3x.png' = 180
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@1x.png' = 76
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@2x.png' = 152
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-83.5x83.5@2x.png' = 167
    'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-1024x1024@1x.png' = 1024
}

try {
    foreach ($entry in $icons.GetEnumerator()) {
        $destination = Join-Path (Join-Path $PSScriptRoot '..') $entry.Key
        $directory = Split-Path -Parent $destination
        [System.IO.Directory]::CreateDirectory($directory) | Out-Null

        $bitmap = New-Object System.Drawing.Bitmap($entry.Value, $entry.Value)
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $graphics.DrawImage($source, 0, 0, $entry.Value, $entry.Value)
            }
            finally {
                $graphics.Dispose()
            }
            $bitmap.Save($destination, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            $bitmap.Dispose()
        }
        Write-Output "$($entry.Key) ($($entry.Value)x$($entry.Value))"
    }
}
finally {
    $source.Dispose()
}
