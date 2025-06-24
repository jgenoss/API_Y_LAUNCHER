using PBLauncher.Models;
using System;
using System.Windows.Forms;

namespace PBLauncher.Services
{
    public enum LauncherState
    {
        Loading,
        Ready,
        Updating,
        Maintenance,
        Error,
        Banned
    }

    public class LauncherStateManager
    {
        public LauncherState CurrentState { get; private set; }
        public string StateMessage { get; private set; }
        public SystemStatus SystemStatus { get; private set; }
        public SystemConfig SystemConfig { get; private set; }

        public event EventHandler<LauncherState> StateChanged;
        public event EventHandler<string> MessageChanged;

        public LauncherStateManager()
        {
            CurrentState = LauncherState.Loading;
            StateMessage = "Iniciando...";
        }

        public void UpdateSystemStatus(SystemStatus status)
        {
            SystemStatus = status;
            UpdateState();
        }

        public void UpdateSystemConfig(SystemConfig config)
        {
            SystemConfig = config;
        }

        private void UpdateState()
        {
            var oldState = CurrentState;
            var oldMessage = StateMessage;

            if (SystemStatus == null)
            {
                SetState(LauncherState.Error, "No se pudo conectar con el servidor");
                return;
            }

            // Verificar modo mantenimiento
            if (SystemStatus.MaintenanceMode)
            {
                SetState(LauncherState.Maintenance, SystemStatus.MaintenanceMessage);
                return;
            }

            // Verificar si el sistema está offline
            if (SystemStatus.Status != "online")
            {
                SetState(LauncherState.Error, "El servidor no está disponible");
                return;
            }

            // Si llegamos aquí, el sistema está online y disponible
            SetState(LauncherState.Ready, "Sistema disponible");

            // Notificar cambios
            if (oldState != CurrentState)
            {
                StateChanged?.Invoke(this, CurrentState);
            }

            if (oldMessage != StateMessage)
            {
                MessageChanged?.Invoke(this, StateMessage);
            }
        }

        private void SetState(LauncherState state, string message)
        {
            CurrentState = state;
            StateMessage = message;
        }

        public bool CanStartGame()
        {
            return CurrentState == LauncherState.Ready;
        }

        public bool CanCheckUpdates()
        {
            return CurrentState == LauncherState.Ready || CurrentState == LauncherState.Updating;
        }

        public bool ShouldShowMaintenanceMessage()
        {
            return CurrentState == LauncherState.Maintenance;
        }

        public void SetBannedState(string reason)
        {
            SetState(LauncherState.Banned, $"Dispositivo baneado: {reason}");
            StateChanged?.Invoke(this, CurrentState);
            MessageChanged?.Invoke(this, StateMessage);
        }

        public void SetUpdatingState(string message)
        {
            SetState(LauncherState.Updating, message);
            StateChanged?.Invoke(this, CurrentState);
            MessageChanged?.Invoke(this, StateMessage);
        }

        public void SetErrorState(string error)
        {
            SetState(LauncherState.Error, error);
            StateChanged?.Invoke(this, CurrentState);
            MessageChanged?.Invoke(this, StateMessage);
        }
    }
}