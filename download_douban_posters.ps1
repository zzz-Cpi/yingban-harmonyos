$ErrorActionPreference = "Continue"

$outputDir = "entry\src\main\resources\base\media"
$outputDir = Resolve-Path $outputDir
Write-Host "Output dir: $outputDir" -ForegroundColor Cyan

$movies = @(
    @{ name = "poster_fanhua"; keyword = "繁花 电视剧 2023" },
    @{ name = "poster_qingyunian"; keyword = "庆余年 第二季 2024" },
    @{ name = "poster_aletai"; keyword = "我的阿勒泰 电视剧" },
    @{ name = "poster_feichi"; keyword = "飞驰人生2 电影" },
    @{ name = "poster_zhongdiba"; keyword = "种地吧 第二季 综艺" },
    @{ name = "poster_bushanliang"; keyword = "不够善良的我们 电视剧" },
    @{ name = "poster_langyabang"; keyword = "琅琊榜 电视剧 2015" },
    @{ name = "poster_kuangbiao"; keyword = "狂飙 电视剧 2023" },
    @{ name = "poster_manchangdeji"; keyword = "漫长的季节 电视剧" },
    @{ name = "poster_waipodexinshijie"; keyword = "外婆的新世界 电视剧" },
    @{ name = "poster_taochubaihuyuan"; keyword = "逃出白垩纪 电影" },
    @{ name = "poster_meiguidagushi"; keyword = "玫瑰的故事 电视剧 2024" },
    @{ name = "poster_jinyongwuxia"; keyword = "金庸武侠世界 电视剧" },
    @{ name = "poster_moyuyunjian"; keyword = "墨雨云间 电视剧" },
    @{ name = "poster_duhuanian"; keyword = "度华年 电视剧" },
    @{ name = "poster_relaguangtang"; keyword = "热辣滚烫 电影" },
    @{ name = "poster_diershitiao"; keyword = "第二十条 电影" },
    @{ name = "poster_womenyiqi"; keyword = "我们一起摇太阳 电影" },
    @{ name = "poster_xiongchumo"; keyword = "熊出没 逆转时空 电影" },
    @{ name = "poster_hongtanxiansheng"; keyword = "红毯先生 电影" },
    @{ name = "poster_dahongbao"; keyword = "大红包 电影" },
    @{ name = "poster_saohei"; keyword = "扫黑 决不放弃 电影" },
    @{ name = "poster_aletai2"; keyword = "我的阿勒泰 电视剧" },
    @{ name = "poster_yanxinji"; keyword = "颜心记 电视剧" }
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
    $keyword = $m.keyword
    $outPath = Join-Path $outputDir "$name.jpg"
    
    if (Test-Path $outPath) {
        $sz = (Get-Item $outPath).Length
        if ($sz -gt 10000) {
            Write-Host "SKIP: $name (already exists)" -ForegroundColor Cyan
            $success++
            continue
        }
    }
    
    Write-Host "Searching: $keyword" -ForegroundColor Yellow
    
    try {
        $encoded = [Uri]::EscapeDataString($keyword)
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
            Write-Host "  FAIL (no poster found in results)" -ForegroundColor Red
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
