// lib/features/app_management/domain/logic/nudge_logic.dart

class NudgeLogic {
  static String getTitle(double intensity) {
    if (intensity < 0.3) return "Gentle Reminder";
    if (intensity < 0.7) return "ReAlign Nudge";
    return "Focus Required!";
  }

  static String getBody(double intensity, String category) {
    if (intensity < 0.3) {
      return "Would you like to switch to your $category apps?";
    } else if (intensity < 0.7) {
      return "It's time to focus on your $category goals.";
    } else {
      return "Put down the distractions. Open your $category apps NOW.";
    }
  }
}
