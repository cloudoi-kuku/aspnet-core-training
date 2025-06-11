#!/usr/bin/env pwsh

# Azure Container Apps Auto-Scaling Test Script
# This script generates load to test auto-scaling behavior

param(
    [Parameter(Mandatory=$true)]
    [string]$AppUrl,
    
    [Parameter(Mandatory=$false)]
    [int]$ConcurrentRequests = 50,
    
    [Parameter(Mandatory=$false)]
    [int]$DurationMinutes = 5,
    
    [Parameter(Mandatory=$false)]
    [int]$RequestDelayMs = 100
)

Write-Host "🧪 Azure Container Apps Auto-Scaling Load Test" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Target URL: $AppUrl" -ForegroundColor Yellow
Write-Host "Concurrent Requests: $ConcurrentRequests" -ForegroundColor Yellow
Write-Host "Duration: $DurationMinutes minutes" -ForegroundColor Yellow
Write-Host "Request Delay: $RequestDelayMs ms" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Validate URL
if (-not $AppUrl.StartsWith("http")) {
    $AppUrl = "https://$AppUrl"
}

# Test endpoints
$endpoints = @(
    "$AppUrl/health",
    "$AppUrl/api/products",
    "$AppUrl/api/products/1"
)

Write-Host "🔍 Testing endpoint availability..." -ForegroundColor Yellow
foreach ($endpoint in $endpoints) {
    try {
        $response = Invoke-WebRequest -Uri $endpoint -Method GET -TimeoutSec 10
        Write-Host "✅ $endpoint - Status: $($response.StatusCode)" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ $endpoint - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🚀 Starting load test..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the test early" -ForegroundColor Yellow
Write-Host ""

# Statistics tracking
$script:totalRequests = 0
$script:successfulRequests = 0
$script:failedRequests = 0
$script:responseTimes = @()

# Function to make HTTP requests
function Invoke-LoadTestRequest {
    param($Url, $RequestId)
    
    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 30
        $stopwatch.Stop()
        
        $script:totalRequests++
        $script:successfulRequests++
        $script:responseTimes += $stopwatch.ElapsedMilliseconds
        
        if ($RequestId % 100 -eq 0) {
            Write-Host "Request $RequestId - Status: $($response.StatusCode) - Time: $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Green
        }
    }
    catch {
        $script:totalRequests++
        $script:failedRequests++
        
        if ($RequestId % 100 -eq 0) {
            Write-Host "Request $RequestId - Failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Calculate end time
$endTime = (Get-Date).AddMinutes($DurationMinutes)
$requestId = 0

# Create job pool for concurrent requests
$jobs = @()
$maxJobs = $ConcurrentRequests

Write-Host "⏱️ Test will run until: $($endTime.ToString('HH:mm:ss'))" -ForegroundColor Cyan
Write-Host ""

# Main load test loop
while ((Get-Date) -lt $endTime) {
    # Clean up completed jobs
    $jobs = $jobs | Where-Object { $_.State -eq 'Running' }
    
    # Start new jobs if under the limit
    while ($jobs.Count -lt $maxJobs -and (Get-Date) -lt $endTime) {
        $requestId++
        $endpoint = $endpoints | Get-Random
        
        $job = Start-Job -ScriptBlock {
            param($Url, $ReqId, $FunctionDef)
            
            # Re-define the function in the job scope
            Invoke-Expression $FunctionDef
            Invoke-LoadTestRequest -Url $Url -RequestId $ReqId
            
        } -ArgumentList $endpoint, $requestId, (Get-Command Invoke-LoadTestRequest).Definition
        
        $jobs += $job
        
        # Small delay between starting requests
        Start-Sleep -Milliseconds $RequestDelayMs
    }
    
    # Display progress every 30 seconds
    if ($requestId % 300 -eq 0) {
        $elapsed = (Get-Date) - (Get-Date).AddMinutes(-$DurationMinutes).AddMinutes($DurationMinutes - (($endTime - (Get-Date)).TotalMinutes))
        Write-Host "📊 Progress: $requestId requests sent, $($script:successfulRequests) successful, $($script:failedRequests) failed" -ForegroundColor Cyan
    }
    
    Start-Sleep -Milliseconds 100
}

# Wait for remaining jobs to complete
Write-Host ""
Write-Host "⏳ Waiting for remaining requests to complete..." -ForegroundColor Yellow
$jobs | Wait-Job | Out-Null
$jobs | Remove-Job

# Calculate statistics
$avgResponseTime = if ($script:responseTimes.Count -gt 0) { 
    ($script:responseTimes | Measure-Object -Average).Average 
} else { 0 }

$maxResponseTime = if ($script:responseTimes.Count -gt 0) { 
    ($script:responseTimes | Measure-Object -Maximum).Maximum 
} else { 0 }

$minResponseTime = if ($script:responseTimes.Count -gt 0) { 
    ($script:responseTimes | Measure-Object -Minimum).Minimum 
} else { 0 }

$successRate = if ($script:totalRequests -gt 0) { 
    ($script:successfulRequests / $script:totalRequests) * 100 
} else { 0 }

# Display results
Write-Host ""
Write-Host "📊 Load Test Results" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Total Requests: $($script:totalRequests)" -ForegroundColor White
Write-Host "Successful: $($script:successfulRequests)" -ForegroundColor Green
Write-Host "Failed: $($script:failedRequests)" -ForegroundColor Red
Write-Host "Success Rate: $($successRate.ToString('F2'))%" -ForegroundColor Yellow
Write-Host ""
Write-Host "Response Times:" -ForegroundColor Cyan
Write-Host "  Average: $($avgResponseTime.ToString('F2'))ms" -ForegroundColor White
Write-Host "  Minimum: $($minResponseTime)ms" -ForegroundColor White
Write-Host "  Maximum: $($maxResponseTime)ms" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# Provide monitoring commands
Write-Host ""
Write-Host "🔍 Monitor Auto-Scaling Results:" -ForegroundColor Yellow
Write-Host "Check current replicas:" -ForegroundColor Cyan
Write-Host "  az containerapp replica list --name <app-name> --resource-group <rg-name>" -ForegroundColor White
Write-Host ""
Write-Host "View scaling logs:" -ForegroundColor Cyan
Write-Host "  az containerapp logs show --name <app-name> --resource-group <rg-name> --type system" -ForegroundColor White
Write-Host ""
Write-Host "Monitor metrics in Azure Portal:" -ForegroundColor Cyan
Write-Host "  Navigate to your Container App > Monitoring > Metrics" -ForegroundColor White

Write-Host ""
Write-Host "✅ Load test completed!" -ForegroundColor Green
