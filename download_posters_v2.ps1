$ErrorActionPreference = "Continue"

$outputDir = "entry\src\main\resources\base\media"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}
$outputDir = Resolve-Path $outputDir
Write-Host "Output dir: $outputDir" -ForegroundColor Cyan

$movies = @(
    @{ name = "poster_fanhua"; keyword = "繁花 电视剧 海报" },
    @{ name = "poster_qingyunian"; keyword = "庆余年第二季 海报" },
    @{ name = "poster_aletai"; keyword = "我的阿勒泰 电视剧 海报" },
    @{ name = "poster_feichi"; keyword = "飞驰人生2 电影 海报" },
    @{ name = "poster_zhongdiba"; keyword = "种地吧第二季 综艺 海报" },
    @{ name = "poster_bushanliang"; keyword = "不够善良的我们 电视剧 海报" },
    @{ name = "poster_langyabang"; keyword = "琅琊榜 电视剧 海报" },
    @{ name = "poster_kuangbiao"; keyword = "狂飙 电视剧 海报" },
    @{ name = "poster_manchangdeji"; keyword = "漫长的季节 电视剧 海报" },
    @{ name = "poster_waipodexinshijie"; keyword = "外婆的新世界 电视剧 海报" },
    @{ name = "poster_taochubaihuyuan"; keyword = "逃出白垩纪 电影 海报" },
    @{ name = "poster_meiguidagushi"; keyword = "玫瑰的故事 电视剧 海报" },
    @{ name = "poster_jinyongwuxia"; keyword = "金庸武侠世界 电视剧 海报" },
    @{ name = "poster_moyuyunjian"; keyword = "墨雨云间 电视剧 海报" },
    @{ name = "poster_duhuanian"; keyword = "度华年 电视剧 海报" },
    @{ name = "poster_relaguangtang"; keyword = "热辣滚烫 电影 海报" },
    @{ name = "poster_diershitiao"; keyword = "第二十条 电影 海报" },
    @{ name = "poster_womenyiqi"; keyword = "我们一起摇太阳 电影 海报" },
    @{ name = "poster_xiongchumo"; keyword = "熊出没逆转时空 电影 海报" },
    @{ name = "poster_hongtanxiansheng"; keyword = "红毯先生 电影 海报" },
    @{ name = "poster_dahongbao"; keyword = "大红包 电影 海报" },
    @{ name = "poster_saohei"; keyword = "扫黑决不放弃 电影 海报" },
    @{ name = "poster_aletai2"; keyword = "我的阿勒泰 电视剧 海报" },
    @{ name = "poster_yanxinji"; keyword = "颜心记 电视剧 海报" }
)

$success = 0
$fail = 0
$headers = @{
    "User-Agent" = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
    "Accept-Language" = "zh-CN,zh;q=0.9,en;q=0.8"
}

function Download-Image {
    param([string]$url, [string]$outPath, [hashtable]$hdrs)
    
    try {
        Invoke-WebRequest -Uri $url -Headers $hdrs -OutFile $outPath -TimeoutSec 20 -UseBasicParsing
        $sz = (Get-Item $outPath).Length
        if ($sz -gt 5000) {
            return $true
        } else {
            if (Test-Path $outPath) { Remove-Item $outPath -Force }
            return $false
        }
    } catch {
        if (Test-Path $outPath) { Remove-Item $outPath -Force }
        return $false
    }
}

function Try-DoubanMobile {
    param([string]$keyword, [string]$outPath, [hashtable]$hdrs)
    
    try {
        $searchUrl = "https://m.douban.com/search/?query=" + [Uri]::EscapeDataString($keyword) + "&type=movie"
        $resp = Invoke-WebRequest -Uri $searchUrl -Headers $hdrs -TimeoutSec 15 -UseBasicParsing
        $content = $resp.Content
        
        $pattern = 'https?://img[^"'' ]*doubanio\.com/view/photo/[ms]_ratio_poster/public/p\d+\.(?:jpg|webp|jpeg)'
        $found = [regex]::Matches($content, $pattern)
        
        if ($found.Count -eq 0) {
            $pattern2 = 'https?://img[^"'' ]*doubanio\.com/view/photo/s_ratio_poster/public/p\d+\.(?:jpg|webp|jpeg)'
            $found = [regex]::Matches($content, $pattern2)
        }
        
        if ($found.Count -gt 0) {
            $imgUrl = $found[0].Value
            Write-Host "  [Douban] Found: $imgUrl" -ForegroundColor Gray
            return Download-Image -url $imgUrl -outPath $outPath -hdrs $hdrs
        }
        return $false
    } catch {
        Write-Host "  [Douban] Error: $($_.Exception.Message)" -ForegroundColor DarkGray
        return $false
    }
}

function Try-BingImage {
    param([string]$keyword, [string]$outPath, [hashtable]$hdrs)
    
    try {
        $searchUrl = "https://cn.bing.com/images/search?q=" + [Uri]::EscapeDataString($keyword + " 海报 高清") + "&form=HDRSC2&first=1"
        $resp = Invoke-WebRequest -Uri $searchUrl -Headers $hdrs -TimeoutSec 15 -UseBasicParsing
        $content = $resp.Content
        
        $pattern = 'https?://[^"'' ]+\.(?:jpg|jpeg|webp|png)'
        $found = [regex]::Matches($content, $pattern)
        
        foreach ($match in $found) {
            $url = $match.Value
            if ($url -match "bing|microsoft|msn" -or $url.Length -lt 50) { continue }
            if ($url -match "poster|cover|p\d+" -or $url -match "douban|imdb|themoviedb") {
                Write-Host "  [Bing] Trying: $url" -ForegroundColor Gray
                if (Download-Image -url $url -outPath $outPath -hdrs $hdrs) {
                    return $true
                }
            }
        }
        
        foreach ($match in $found | Select-Object -First 20) {
            $url = $match.Value
            if ($url -match "bing|microsoft|msn|svg|gif" -or $url.Length -lt 50) { continue }
            Write-Host "  [Bing] Trying: $url" -ForegroundColor Gray
            if (Download-Image -url $url -outPath $outPath -hdrs $hdrs) {
                return $true
            }
        }
        return $false
    } catch {
        Write-Host "  [Bing] Error: $($_.Exception.Message)" -ForegroundColor DarkGray
        return $false
    }
}

function Try-PicsumFallback {
    param([string]$keyword, [string]$outPath)
    
    try {
        $seed = $keyword.GetHashCode().ToString("X")
        $url = "https://picsum.photos/seed/$seed/500/750"
        Write-Host "  [Fallback] Using picsum.photos seed=$seed" -ForegroundColor Gray
        return Download-Image -url $url -outPath $outPath -hdrs @{}
    } catch {
        Write-Host "  [Fallback] Error: $($_.Exception.Message)" -ForegroundColor DarkGray
        return $false
    }
}

foreach ($m in $movies) {
    $name = $m.name
    $keyword = $m.keyword
    $outPath = Join-Path $outputDir "$name.jpg"
    
    if (Test-Path $outPath) {
        $sz = (Get-Item $outPath).Length
        if ($sz -gt 5000) {
            Write-Host "SKIP: $name (already exists, $([math]::Round($sz/1024, 1)) KB)" -ForegroundColor Cyan
            $success++
            continue
        }
    }
    
    Write-Host "Downloading: $name" -ForegroundColor Yellow
    
    $ok = $false
    
    if (-not $ok) {
        $ok = Try-DoubanMobile -keyword $keyword -outPath $outPath -hdrs $headers
    }
    
    if (-not $ok) {
        $ok = Try-BingImage -keyword $keyword -outPath $outPath -hdrs $headers
    }
    
    if (-not $ok) {
        $ok = Try-PicsumFallback -keyword $keyword -outPath $outPath
    }
    
    if ($ok) {
        $sz = (Get-Item $outPath).Length
        Write-Host "  OK ($([math]::Round($sz/1024, 1)) KB)" -ForegroundColor Green
        $success++
    } else {
        Write-Host "  FAIL (all sources failed)" -ForegroundColor Red
        $fail++
    }
}

Write-Host ""
Write-Host "========================" -ForegroundColor Cyan
Write-Host "Done! Success: $success, Fail: $fail" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
