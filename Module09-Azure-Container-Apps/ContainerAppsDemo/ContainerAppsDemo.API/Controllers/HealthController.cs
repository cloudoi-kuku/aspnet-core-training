using Microsoft.AspNetCore.Mvc;

namespace ContainerAppsDemo.API.Controllers;

[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    private readonly ILogger<HealthController> _logger;

    public HealthController(ILogger<HealthController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    public IActionResult Get()
    {
        _logger.LogInformation("Health check requested");

        var healthStatus = new
        {
            Status = "Healthy",
            Timestamp = DateTime.UtcNow,
            Version = "1.0.0",
            Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT"),
            MachineName = Environment.MachineName
        };

        return Ok(healthStatus);
    }

    [HttpGet("ready")]
    public IActionResult Ready()
    {
        // Add readiness checks here (database connectivity, external services, etc.)
        return Ok(new { Status = "Ready", Timestamp = DateTime.UtcNow });
    }

    [HttpGet("live")]
    public IActionResult Live()
    {
        // Add liveness checks here (application responsiveness, memory usage, etc.)
        return Ok(new { Status = "Live", Timestamp = DateTime.UtcNow });
    }
}
