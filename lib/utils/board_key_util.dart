String boardKeyFor(String boardName) {
  switch (boardName) {
    case '전체글':
      return 'all';
    case '공지':
      return 'notice';
    case '인기':
      return 'popular';
    case '동네 일상':
      return 'life';
    case '동네 정보':
      return 'info';
    case '맛집 추천':
      return 'food';
    default:
      return 'unknown';
  }
}
