$ErrorActionPreference = "Continue"

$outputDir = "entry\src\main\resources\base\media"
$outputDir = Resolve-Path $outputDir
Write-Host "Output dir: $outputDir" -ForegroundColor Cyan

$posters = @(
    @{ name = "poster_fanhua"; url = "https://img3.doubanio.com/view/photo/s_ratio_poster/public/p2902705337.webp" },
    @{ name = "poster_qingyunian"; url = "https://img1.doubanio.com/view/photo/s_ratio_poster/public/p2907968100.webp" },
    @{ name = "poster_aletai"; url = "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2905618615.webp" },
    @{ name = "poster_feichi"; url = "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2903066285.webp" },
    @{ name = "poster_zhongdiba"; url = "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2903956496.webp" },
    @{ name = "poster_bushanliang"; url = "https://img3.doubanio.com/view/photo/s_ratio_poster/public/p2899493402.webp" },
    @{ name = "poster_langyabang"; url = "https://img1.doubanio.com/view/photo/s_ratio_poster/public/p2271982968.jpg" },
    @{ name = "poster_kuangbiao"; url = "https://img2.doubanio.com/view/photo/s_ratio_poster/public/p2886376181.webp" },
    @{ name = "poster_manchangdeji"; url = "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2890906384.jpg" },
    @{ name = "poster_waipodexinshijie"; url = "https://img1.doubanio.com/view/photo/s_ratio_poster/public/p2892024039.jpg" },
    @{ name = "poster_taochubaihuyuan"; url = "https://img3.doubanio.com/view/photo/s_ratio_poster/public/p2888964597.jpg" },
    @{ name = "poster_meiguidagushi"; url = "https://img2.doubanio.com/view/photo/s_ratio_poster/public/p2909198461.jpg" },
    @{ name = "poster_jinyongwuxia"; url = "https://img1.doubanio.com/view/photo/s_ratio_poster/public/p2910776309.jpg" },
    @{ name = "poster_moyuyunjian"; url = "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2908954736.jpg" },
    @{ name = "poster_duhuanian"; url = "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2909909594.jpg" },
    @{ name = "poster_relaguangtang"; url = "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2904304396.jpg" },
    @{ name = "poster_diershitiao"; url = "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2903145026.jpg" },
    @{ name = "poster_womenyiqi"; url = "https://img3.doubanio.com/view/photo/s_ratio_poster/public/p2904467472.jpg" },
    @{ name = "poster_xiongchumo"; url = "https://img3.doubanio.com/view/photo/s_ratio_poster/public/p2902482452.jpg" },
    @{ name = "poster_hongtanxiansheng"; url = "https://img1.doubanio.com/view/photo/s_ratio_poster/public/p2905249058.jpg" },
    @{ name = "poster_dahongbao"; url = "https://img3.doubanio.com/view/photo/s_ratio_poster/public/p2630893317.jpg" },
    @{ name = "poster_saohei"; url = "https://img1.doubanio.com/view/photo/s_ratio_poster/public/p2907965629.jpg" },
    @{ name = "poster_aletai2"; url = "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2905618615.webp" },
    @{ name = "poster_yanxinji"; url = "https://img1.doubanio.com/view/photo/s_ratio_poster/public/p2909713609.jpg" }
)

$success = 0
$fail = 0

$headers = @{
    "User-Agent" = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
    "Accept" = "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8"
    "Accept-Language" = "zh-CN,zh;q=0.9,en;q=0.8"
    "Referer" = "https://m.douban.com/"
}

foreach ($p in $posters) {
    $name = $p.name
    $url = $p.url
    $outPath = Join-Path $outputDir "$name.jpg"
    
    if (Test-Path $outPath) {
        $sz = (Get-Item $outPath).Length
        if ($sz -gt 10000) {
            Write-Host "SKIP: $name" -ForegroundColor Cyan
            $success++
            continue
        }
    }
    
    Write-Host "Downloading: $name" -ForegroundColor Yellow
    
    try {
        Invoke-WebRequest -Uri $url -Headers $headers -OutFile $outPath -TimeoutSec 30 -UseBasicParsing
        
        $sz = (Get-Item $outPath).Length
        if ($sz -gt 5000) {
            Write-Host "  OK ($([math]::Round($sz/1024, 1)) KB)" -ForegroundColor Green
            $success++
        } else {
            Write-Host "  FAIL (too small: $sz bytes)" -ForegroundColor Red
            if (Test-Path $outPath) { Remove-Item $outPath -Force }
            $fail++
        }
    } catch {
        Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
        if (Test-Path $outPath) { Remove-Item $outPath -Force }
        $fail++
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "========================" -ForegroundColor Cyan
Write-Host "Done! Success: $success, Fail: $fail" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
