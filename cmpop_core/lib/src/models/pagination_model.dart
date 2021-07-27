enum PaginationBtnType { prev, next, page }
enum PaginationType { carousel, cube }

class PaginationModel {
  PaginationModel({this.active = false, this.page, this.label, this.onClick, this.btnType, this.disabled = false});
  bool active = false;
  bool disabled = false;
  int page = 1;
  String label = '1';
  PaginationBtnType btnType;
  Function onClick;
}
