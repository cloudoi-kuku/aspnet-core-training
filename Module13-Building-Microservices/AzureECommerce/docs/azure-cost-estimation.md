# Azure Cost Estimation

## Monthly Cost Breakdown (Minimal Usage)

| Service | Configuration | Estimated Cost |
|---------|--------------|----------------|
| Container Apps | 2 apps, 0.5 vCPU, 1GB RAM each | ~$10 |
| Azure SQL | Basic tier, 2 databases | ~$10 |
| Container Registry | Basic tier | ~$5 |
| Application Insights | Basic ingestion | ~$5 |
| **Total** | | **~`$30/month** |

## Free Tier Benefits
- First 180,000 vCPU-seconds free
- First 360,000 GB-seconds free  
- First 2 million requests free
- 5GB Application Insights data free

## Cost Optimization Tips
1. Scale Container Apps to zero when not in use
2. Use Basic tier for SQL in development
3. Set up cost alerts in Azure Portal
4. Review and optimize regularly
