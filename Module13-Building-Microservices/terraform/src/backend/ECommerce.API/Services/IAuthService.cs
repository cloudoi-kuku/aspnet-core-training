using ECommerce.API.DTOs;

namespace ECommerce.API.Services;

public interface IAuthService
{
    Task<AuthResult> LoginAsync(LoginRequest loginRequest);
    Task<AuthResult> RegisterAsync(RegisterRequest registerRequest);
    Task<AuthResult> RefreshTokenAsync(string refreshToken);
    Task LogoutAsync(string userId);
    Task<bool> ValidateTokenAsync(string token);
}

public class AuthResult
{
    public bool Success { get; set; }
    public string Token { get; set; } = string.Empty;
    public string RefreshToken { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public UserDto? User { get; set; }
}

public class UserDto
{
    public int Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Address { get; set; }
    public string Role { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}