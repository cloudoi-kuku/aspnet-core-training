# Simple Dockerfile for Azure Container Apps
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ContainerAppsDemo.API/ ./ContainerAppsDemo.API/
WORKDIR /src/ContainerAppsDemo.API
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "ContainerAppsDemo.API.dll"]
