$ErrorActionPreference = "Continue"

$outputDir = "entry\src\main\resources\base\media"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}
Write-Host "Output dir: $(Resolve-Path $outputDir)" -ForegroundColor Cyan

$movies = @(
    ,@("34874646", "poster_fanhua"),
    ,@("34937650", "poster_qingyunian"),
    ,@("36522955", "poster_aletai"),
    ,@("36369452", "poster_feichi"),
    ,@("36571420", "poster_zhongdiba"),
    ,@("36589909", "poster_bushanliang"),
    ,@("25750923", "poster_langyabang"),
    ,@("35474009", "poster_kuangbiao"),
    ,@("35588177", "poster_manchangdeji"),
    ,@("35876302", "poster_waipodexinshijie"),
    ,@("36389905", "poster_taochubaihuyuan"),
    ,@("36522946", "poster_meiguidagushi"),
    ,@("36279229", "poster_jinyongwuxia"),
    ,@("36522834", "poster_moyuyunjian"),
    ,@("36522833", "poster_duhuanian"),
    ,@("36091087", "poster_relaguangtang"),
    ,@("36222669", "poster_diershitiao"),
    ,@("36174309", "poster_womenyiqi"),
    ,@("36418564", "poster_xiongchumo"),
    ,@("35392727", "poster_hongtanxiansheng"),
    ,@("35231450", "poster_dahongbao"),
    ,@("36389904", "poster_saohei")
)

$success = 0
$fail = 0
$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Referer" = "https://movie.douban.com/"
}

foreach ($m in $movies) {
    $id = $m[0]
    $name = $m[1]
    Write-Host "Downloading: $name ($id)" -ForegroundColor Yellow
    
    try {
        $url = "https://movie.douban.com/subject/$id/"
        $resp = Invoke-WebRequest -Uri $url -Headers $headers -TimeoutSec 15 -UseBasicParsing
        $content = $resp.Content
        
        $pattern = 'https?://img[^"]*doubanio\.com/view/photo/[ms]_ratio_poster/public/p\d+\.(?:jpg|webp)'
        $found = [regex]::Matches($content, $pattern)
        
        if ($found.Count -eq 0) {
            $pattern2 = 'https?://img[^"]*doubanio\.com/view/photo/l/public/p\d+\.(?:jpg|webp)'
            $found = [regex]::Matches($content, $pattern2)
        }
        
        if ($found.Count -gt 0) {
            $imgUrl = $found[0].Value
            Write-Host "  Found: $imgUrl" -ForegroundColor Gray
            
            $outPath = Join-Path $outputDir "$name.jpg"
            try {
                Invoke-WebRequest -Uri $imgUrl -Headers $headers -OutFile $outPath -TimeoutSec 20 -UseBasicParsing
                $sz = (Get-Item $outPath).Length
                if ($sz -gt 1000) {
                    Write-Host "  OK ($([math]::Round($sz/1024, 1)) KB)" -ForegroundColor Green
                    $success++
                } else {
                    Write-Host "  FAIL (file too small)" -ForegroundColor Red
                    $fail++
                }
            } catch {
                Write-Host "  FAIL download: $($_.Exception.Message)" -ForegroundColor Red
                $fail++
            }
        } else {
            Write-Host "  FAIL (no poster url)" -ForegroundColor Red
            $fail++
        }
    } catch {
        Write-Host "  FAIL fetch: $($_.Exception.Message)" -ForegroundColor Red
        $fail++
    }
}

Write-Host ""
Write-Host "========================" -ForegroundColor Cyan
Write-Host "Done! Success: $success, Fail: $fail" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
