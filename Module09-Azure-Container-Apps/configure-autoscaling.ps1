#!/usr/bin/env pwsh

# Azure Container Apps Auto-Scaling Configuration Script
# This script demonstrates various auto-scaling configurations for Container Apps

param(
    [Parameter(Mandatory=$true)]
    [string]$ContainerAppName,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$false)]
    [string]$ScalingType = "http"
)

Write-Host "🔧 Configuring Auto-Scaling for Azure Container Apps" -ForegroundColor Cyan
Write-Host "Container App: $ContainerAppName" -ForegroundColor Yellow
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Yellow
Write-Host "Scaling Type: $ScalingType" -ForegroundColor Yellow
Write-Host ""

# Function to display scaling concepts
function Explain-AutoScaling {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📚 AUTO-SCALING CONCEPTS" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "Azure Container Apps supports multiple scaling triggers:" -ForegroundColor Yellow
    Write-Host "• HTTP Scaling: Based on concurrent requests per replica" -ForegroundColor White
    Write-Host "• CPU Scaling: Based on CPU utilization percentage" -ForegroundColor White
    Write-Host "• Memory Scaling: Based on memory utilization percentage" -ForegroundColor White
    Write-Host "• Custom Metrics: Based on Azure Monitor metrics" -ForegroundColor White
    Write-Host "• Event-Driven: Based on Azure Service Bus, Storage Queue, etc." -ForegroundColor White
    Write-Host "• Schedule-Based: Scale up/down at specific times" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
}

Explain-AutoScaling

# Check if Container App exists
Write-Host "Checking if Container App exists..." -ForegroundColor Yellow
$appExists = az containerapp show --name $ContainerAppName --resource-group $ResourceGroupName --query "name" -o tsv 2>$null
if (-not $appExists) {
    Write-Error "Container App '$ContainerAppName' not found in resource group '$ResourceGroupName'"
    exit 1
}
Write-Host "✅ Container App found!" -ForegroundColor Green

switch ($ScalingType.ToLower()) {
    "http" {
        Write-Host "🌐 Configuring HTTP-based auto-scaling..." -ForegroundColor Cyan
        
        # HTTP scaling configuration
        az containerapp update `
            --name $ContainerAppName `
            --resource-group $ResourceGroupName `
            --min-replicas 1 `
            --max-replicas 10 `
            --scale-rule-name "http-scale-rule" `
            --scale-rule-type "http" `
            --scale-rule-http-concurrency 10
            
        Write-Host "✅ HTTP scaling configured:" -ForegroundColor Green
        Write-Host "   • Min replicas: 1" -ForegroundColor White
        Write-Host "   • Max replicas: 10" -ForegroundColor White
        Write-Host "   • Concurrent requests per replica: 10" -ForegroundColor White
    }
    
    "cpu" {
        Write-Host "🖥️ Configuring CPU-based auto-scaling..." -ForegroundColor Cyan
        
        # CPU scaling configuration
        az containerapp update `
            --name $ContainerAppName `
            --resource-group $ResourceGroupName `
            --min-replicas 2 `
            --max-replicas 15 `
            --scale-rule-name "cpu-scale-rule" `
            --scale-rule-type "cpu" `
            --scale-rule-metadata "type=Utilization" "value=70"
            
        Write-Host "✅ CPU scaling configured:" -ForegroundColor Green
        Write-Host "   • Min replicas: 2" -ForegroundColor White
        Write-Host "   • Max replicas: 15" -ForegroundColor White
        Write-Host "   • CPU threshold: 70%" -ForegroundColor White
    }
    
    "memory" {
        Write-Host "🧠 Configuring Memory-based auto-scaling..." -ForegroundColor Cyan
        
        # Memory scaling configuration
        az containerapp update `
            --name $ContainerAppName `
            --resource-group $ResourceGroupName `
            --min-replicas 1 `
            --max-replicas 8 `
            --scale-rule-name "memory-scale-rule" `
            --scale-rule-type "memory" `
            --scale-rule-metadata "type=Utilization" "value=80"
            
        Write-Host "✅ Memory scaling configured:" -ForegroundColor Green
        Write-Host "   • Min replicas: 1" -ForegroundColor White
        Write-Host "   • Max replicas: 8" -ForegroundColor White
        Write-Host "   • Memory threshold: 80%" -ForegroundColor White
    }
    
    "combined" {
        Write-Host "🔄 Configuring Combined auto-scaling (HTTP + CPU)..." -ForegroundColor Cyan
        
        # Create scaling rules JSON file
        $scalingRules = @'
{
  "scale": {
    "minReplicas": 2,
    "maxReplicas": 20,
    "rules": [
      {
        "name": "http-scale-rule",
        "http": {
          "metadata": {
            "concurrentRequests": "15"
          }
        }
      },
      {
        "name": "cpu-scale-rule",
        "custom": {
          "type": "cpu",
          "metadata": {
            "type": "Utilization",
            "value": "75"
          }
        }
      }
    ]
  }
}
'@
        
        $scalingRules | Out-File -FilePath "scaling-rules.json" -Encoding UTF8
        
        # Apply combined scaling rules
        az containerapp update `
            --name $ContainerAppName `
            --resource-group $ResourceGroupName `
            --yaml scaling-rules.json
            
        Write-Host "✅ Combined scaling configured:" -ForegroundColor Green
        Write-Host "   • Min replicas: 2" -ForegroundColor White
        Write-Host "   • Max replicas: 20" -ForegroundColor White
        Write-Host "   • HTTP: 15 concurrent requests per replica" -ForegroundColor White
        Write-Host "   • CPU: 75% utilization threshold" -ForegroundColor White
        
        Remove-Item "scaling-rules.json" -Force
    }
    
    "advanced" {
        Write-Host "⚡ Configuring Advanced auto-scaling with multiple triggers..." -ForegroundColor Cyan
        
        # Advanced scaling with multiple rules
        $advancedScaling = @'
{
  "properties": {
    "template": {
      "scale": {
        "minReplicas": 1,
        "maxReplicas": 25,
        "rules": [
          {
            "name": "http-requests",
            "http": {
              "metadata": {
                "concurrentRequests": "20"
              }
            }
          },
          {
            "name": "cpu-utilization",
            "custom": {
              "type": "cpu",
              "metadata": {
                "type": "Utilization",
                "value": "70"
              }
            }
          },
          {
            "name": "memory-utilization", 
            "custom": {
              "type": "memory",
              "metadata": {
                "type": "Utilization",
                "value": "85"
              }
            }
          }
        ]
      }
    }
  }
}
'@
        
        $advancedScaling | Out-File -FilePath "advanced-scaling.json" -Encoding UTF8
        
        # Apply advanced scaling
        az rest --method patch `
            --url "https://management.azure.com/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$ResourceGroupName/providers/Microsoft.App/containerApps/$ContainerAppName?api-version=2022-03-01" `
            --body @advanced-scaling.json
            
        Write-Host "✅ Advanced scaling configured:" -ForegroundColor Green
        Write-Host "   • Min replicas: 1" -ForegroundColor White
        Write-Host "   • Max replicas: 25" -ForegroundColor White
        Write-Host "   • HTTP: 20 concurrent requests" -ForegroundColor White
        Write-Host "   • CPU: 70% threshold" -ForegroundColor White
        Write-Host "   • Memory: 85% threshold" -ForegroundColor White
        
        Remove-Item "advanced-scaling.json" -Force
    }
    
    default {
        Write-Error "Unknown scaling type: $ScalingType"
        Write-Host "Available types: http, cpu, memory, combined, advanced" -ForegroundColor Yellow
        exit 1
    }
}

# Display current scaling configuration
Write-Host ""
Write-Host "📊 Current Scaling Configuration:" -ForegroundColor Cyan
az containerapp show --name $ContainerAppName --resource-group $ResourceGroupName --query "properties.template.scale" -o table

Write-Host ""
Write-Host "🔍 Monitoring Commands:" -ForegroundColor Yellow
Write-Host "View current replicas: az containerapp replica list --name $ContainerAppName --resource-group $ResourceGroupName" -ForegroundColor White
Write-Host "View scaling events: az containerapp logs show --name $ContainerAppName --resource-group $ResourceGroupName --type system" -ForegroundColor White
Write-Host "Monitor metrics: az monitor metrics list --resource /subscriptions/\$(az account show --query id -o tsv)/resourceGroups/$ResourceGroupName/providers/Microsoft.App/containerApps/$ContainerAppName" -ForegroundColor White

Write-Host ""
Write-Host "✅ Auto-scaling configuration completed!" -ForegroundColor Green
