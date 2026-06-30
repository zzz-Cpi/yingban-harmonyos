$ErrorActionPreference = "Continue"

$outputDir = "entry\src\main\resources\base\media"
$outputDir = Resolve-Path $outputDir
Write-Host "Output dir: $outputDir" -ForegroundColor Cyan

$movies = @(
    @{ name = "poster_fanhua"; encoded = "%E7%B9%81%E8%8A%B1%20%E7%94%B5%E8%A7%86%E5%89%A7" },
    @{ name = "poster_qingyunian"; encoded = "%E5%BA%86%E4%BD%99%E5%B9%B4%20%E7%AC%AC%E4%BA%8C%E5%AD%A3" },
    @{ name = "poster_aletai"; encoded = "%E6%88%91%E7%9A%84%E9%98%BF%E5%8B%92%E6%B3%B0%20%E7%94%B5%E8%A7%86%E5%89%A7" },
    @{ name = "poster_feichi"; encoded = "%E9%A3%9E%E9%A9%B0%E4%BA%BA%E7%94%9F2%20%E7%94%B5%E5%BD%B1" },
    @{ name = "poster_zhongdiba"; encoded = "%E7%A7%8D%E5%9C%B0%E5%90%A7%20%E7%AC%AC%E4%BA%8C%E5%AD%A3" },
    @{ name = "poster_bushanliang"; encoded = "%E4%B8%8D%E5%A4%9F%E5%96%84%E8%89%AF%E7%9A%84%E6%88%91%E4%BB%AC" },
    @{ name = "poster_langyabang"; encoded = "%E7%90%85%E7%90%8A%E6%A6%9C%20%E7%94%B5%E8%A7%86%E5%89%A7" },
    @{ name = "poster_kuangbiao"; encoded = "%E7%8B%82%E9%A3%99%20%E7%94%B5%E8%A7%86%E5%89%A7" },
    @{ name = "poster_manchangdeji"; encoded = "%E6%BC%AB%E9%95%BF%E7%9A%84%E5%AD%A3%E8%8A%82%20%E7%94%B5%E8%A7%86%E5%89%A7" },
    @{ name = "poster_waipodexinshijie"; encoded = "%E5%A4%96%E5%A9%86%E7%9A%84%E6%96%B0%E4%B8%96%E7%95%8C%20%E7%94%B5%E8%A7%86%E5%89%A7" },
    @{ name = "poster_taochubaihuyuan"; encoded = "%E9%80%83%E5%87%BA%E7%99%BD%E5%9E%A9%E7%BA%AA%20%E7%94%B5%E5%BD%B1" },
    @{ name = "poster_meiguidagushi"; encoded = "%E7%8E%AB%E7%91%B0%E7%9A%84%E6%95%85%E4%BA%8B%20%E7%94%B5%E8%A7%86%E5%89%A7" },
    @{ name = "poster_jinyongwuxia"; encoded = "%E9%87%91%E5%BA%B8%E6%AD%A6%E4%BE%A0%E4%B8%96%E7%95%8C" },
    @{ name = "poster_moyuyunjian"; encoded = "%E5%A2%A8%E9%9B%A8%E4%BA%91%E9%97%B4%20%E7%94%B5%E8%A7%86%E5%89%A7" },
    @{ name = "poster_duhuanian"; encoded = "%E5%BA%A6%E5%8D%8E%E5%B9%B4%20%E7%94%B5%E8%A7%86%E5%89%A7" },
    @{ name = "poster_relaguangtang"; encoded = "%E7%83%AD%E8%BE%A3%E6%BB%9A%E6%96%AB%20%E7%94%B5%E5%BD%B1" },
    @{ name = "poster_diershitiao"; encoded = "%E7%AC%AC%E4%BA%8C%E5%8D%81%E6%9D%A1%20%E7%94%B5%E5%BD%B1" },
    @{ name = "poster_womenyiqi"; encoded = "%E6%88%91%E4%BB%AC%E4%B8%80%E8%B5%B7%E6%91%87%E5%A4%AA%E9%98%B3" },
    @{ name = "poster_xiongchumo"; encoded = "%E7%86%8A%E5%87%BA%E6%B2%A1%20%E9%80%86%E8%BD%AC%E6%97%B6%E7%A9%BA" },
    @{ name = "poster_hongtanxiansheng"; encoded = "%E7%BA%A2%E6%AF%AF%E5%85%88%E7%94%9F%20%E7%94%B5%E5%BD%B1" },
    @{ name = "poster_dahongbao"; encoded = "%E5%A4%A7%E7%BA%A2%E5%8C%85%20%E7%94%B5%E5%BD%B1" },
    @{ name = "poster_saohei"; encoded = "%E6%89%AB%E9%BB%91%20%E5%86%B3%E4%B8%8D%E6%94%BE%E5%BC%83" },
    @{ name = "poster_aletai2"; encoded = "%E6%88%91%E7%9A%84%E9%98%BF%E5%8B%92%E6%B3%B0%20%E7%94%B5%E8%A7%86%E5%89%A7" },
    @{ name = "poster_yanxinji"; encoded = "%E9%A2%9C%E5%BF%83%E8%AE%B0%20%E7%94%B5%E8%A7%86%E5%89%A7" }
)

$success = 0
$fail = 0

$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8"
    "Accept-Language" = "zh-CN,zh;q=0.9,en;q=0.8"
    "Referer" = "https://movie.douban.com/"
}

foreach ($m in $movies) {
    $name = $m.name
    $encoded = $m.encoded
    $outPath = Join-Path $outputDir "$name.jpg"
    
    if (Test-Path $outPath) {
        $sz = (Get-Item $outPath).Length
        if ($sz -gt 10000) {
            Write-Host "SKIP: $name (already exists)" -ForegroundColor Cyan
            $success++
            continue
        }
    }
    
    Write-Host "Searching: $name" -ForegroundColor Yellow
    
    try {
        $searchUrl = "https://movie.douban.com/subject_search?search_text=$encoded&cat=1002"
        
        $resp = Invoke-WebRequest -Uri $searchUrl -Headers $headers -TimeoutSec 20 -UseBasicParsing
        $content = $resp.Content
        
        $pattern = 'https?://img[^"'' ]*doubanio\.com/view/photo/s_ratio_poster/public/p\d+\.(?:webp|jpg|jpeg)'
        $found = [regex]::Matches($content, $pattern)
        
        if ($found.Count -gt 0) {
            $imgUrl = $found[0].Value
            Write-Host "  Found: $imgUrl" -ForegroundColor Gray
            
            try {
                $imgHeaders = $headers.Clone()
                $imgHeaders["Referer"] = $searchUrl
                Invoke-WebRequest -Uri $imgUrl -Headers $imgHeaders -OutFile $outPath -TimeoutSec 30 -UseBasicParsing
                
                $sz = (Get-Item $outPath).Length
                if ($sz -gt 5000) {
                    Write-Host "  OK ($([math]::Round($sz/1024, 1)) KB)" -ForegroundColor Green
                    $success++
                } else {
                    Write-Host "  FAIL (file too small: $sz bytes)" -ForegroundColor Red
                    if (Test-Path $outPath) { Remove-Item $outPath -Force }
                    $fail++
                }
            } catch {
                Write-Host "  FAIL download: $($_.Exception.Message)" -ForegroundColor Red
                if (Test-Path $outPath) { Remove-Item $outPath -Force }
                $fail++
            }
        } else {
            Write-Host "  FAIL (no poster found)" -ForegroundColor Red
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
