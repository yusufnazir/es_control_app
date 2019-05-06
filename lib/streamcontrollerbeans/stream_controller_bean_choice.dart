class StreamControllerBeanChoice {
  int choiceId;
  int surveyQuestionId;
  bool value;
  int makeSelectedQuestionRequired;
  int makeSelectedQuestionByGroupRequired;

  StreamControllerBeanChoice(
      {this.choiceId,
      this.value,
      this.makeSelectedQuestionRequired,
      this.surveyQuestionId,
      this.makeSelectedQuestionByGroupRequired});
}
