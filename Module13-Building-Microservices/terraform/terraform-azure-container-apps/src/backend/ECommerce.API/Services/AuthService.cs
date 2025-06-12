using ECommerce.API.DTOs;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace ECommerce.API.Services;

public class AuthService : IAuthService
{
    private readonly ILogger<AuthService> _logger;
    private readonly IUserService _userService;
    private readonly IConfiguration _configuration;

    public AuthService(ILogger<AuthService> logger, IUserService userService, IConfiguration configuration)
    {
        _logger = logger;
        _userService = userService;
        _configuration = configuration;
    }

    public async Task<AuthResult> LoginAsync(LoginRequest loginRequest)
    {
        _logger.LogInformation($"Login attempt for email: {loginRequest.Email}");
        
        var user = await _userService.GetUserByEmailAsync(loginRequest.Email);
        
        if (user == null || !VerifyPassword(loginRequest.Password, user.PasswordHash))
        {
            return new AuthResult
            {
                Success = false,
                Message = "Invalid email or password"
            };
        }

        var token = GenerateJwtToken(user);
        var refreshToken = GenerateRefreshToken();

        return new AuthResult
        {
            Success = true,
            Token = token,
            RefreshToken = refreshToken,
            Message = "Login successful",
            User = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Phone = user.Phone,
                Address = user.Address,
                Role = user.Role,
                IsActive = user.IsActive
            }
        };
    }

    public async Task<AuthResult> RegisterAsync(RegisterRequest registerRequest)
    {
        _logger.LogInformation($"Registration attempt for email: {registerRequest.Email}");
        
        var existingUser = await _userService.GetUserByEmailAsync(registerRequest.Email);
        if (existingUser != null)
        {
            return new AuthResult
            {
                Success = false,
                Message = "User with this email already exists"
            };
        }

        var hashedPassword = HashPassword(registerRequest.Password);
        var createUserRequest = new CreateUserRequest
        {
            Email = registerRequest.Email,
            Password = hashedPassword,
            FirstName = registerRequest.FirstName,
            LastName = registerRequest.LastName,
            Phone = registerRequest.Phone,
            Address = registerRequest.Address,
            Role = "Customer"
        };

        var user = await _userService.CreateAsync(createUserRequest);
        var token = GenerateJwtToken(user);
        var refreshToken = GenerateRefreshToken();

        return new AuthResult
        {
            Success = true,
            Token = token,
            RefreshToken = refreshToken,
            Message = "Registration successful",
            User = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Phone = user.Phone,
                Address = user.Address,
                Role = user.Role,
                IsActive = user.IsActive
            }
        };
    }

    public async Task<AuthResult> RefreshTokenAsync(string refreshToken)
    {
        // In a real implementation, validate the refresh token from storage
        // For now, we'll just generate a new token
        return await Task.FromResult(new AuthResult
        {
            Success = true,
            Token = GenerateJwtToken(new UserDto { Id = 1, Email = "user@example.com", Role = "Customer" }),
            RefreshToken = GenerateRefreshToken(),
            Message = "Token refreshed successfully"
        });
    }

    public async Task LogoutAsync(string userId)
    {
        _logger.LogInformation($"User {userId} logged out");
        // In a real implementation, invalidate the refresh token
        await Task.CompletedTask;
    }

    public async Task<bool> ValidateTokenAsync(string token)
    {
        try
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_configuration["JwtSettings:SecretKey"] ?? "your-secret-key");
            
            tokenHandler.ValidateToken(token, new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(key),
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidIssuer = _configuration["JwtSettings:Issuer"],
                ValidAudience = _configuration["JwtSettings:Audience"],
                ClockSkew = TimeSpan.Zero
            }, out SecurityToken validatedToken);

            return await Task.FromResult(true);
        }
        catch
        {
            return await Task.FromResult(false);
        }
    }

    private string GenerateJwtToken(UserDto user)
    {
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.ASCII.GetBytes(_configuration["JwtSettings:SecretKey"] ?? "your-secret-key");
        
        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim("UserId", user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Name, $"{user.FirstName} {user.LastName}"),
                new Claim(ClaimTypes.Role, user.Role)
            }),
            Expires = DateTime.UtcNow.AddDays(7),
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature),
            Issuer = _configuration["JwtSettings:Issuer"],
            Audience = _configuration["JwtSettings:Audience"]
        };

        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }

    private string GenerateJwtToken(dynamic user)
    {
        var userDto = new UserDto
        {
            Id = user.Id,
            Email = user.Email,
            FirstName = user.FirstName,
            LastName = user.LastName,
            Role = user.Role
        };
        return GenerateJwtToken(userDto);
    }

    private string GenerateRefreshToken()
    {
        return Guid.NewGuid().ToString();
    }

    private string HashPassword(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password);
    }

    private bool VerifyPassword(string password, string hash)
    {
        return BCrypt.Net.BCrypt.Verify(password, hash);
    }
}