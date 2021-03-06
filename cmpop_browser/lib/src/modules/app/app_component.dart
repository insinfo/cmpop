import 'package:angular/angular.dart';

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:cmpop_browser/src/modules/home/components/footer_principal/footer_principal.dart';
import 'package:cmpop_browser/src/modules/home/components/header_principal/header_principal.dart';
import 'package:cmpop_browser/src/shared/components/midia-carousel/midia_carousel.dart';
import 'package:cmpop_browser/src/shared/routes/route_paths.dart';
import 'package:cmpop_browser/src/shared/routes/routes.dart';
import 'package:cmpop_browser/src/shared/services/header_footer_service.dart';

/*const List<dynamic> materialDirectives = [
  AutoDismissDirective,
  AutoFocusDirective,
  ButtonDirective,
  CachingDeferredContentDirective,
  CheckNonNegativeValidator,
  ClickableTooltipTargetDirective,
  DarkThemeDirective,
  DateInputDirective,
  DateRangeEditorComponent,
  DateRangeInputComponent,
  DeferredContentDirective,
  displayNameRendererDirective,
  DropdownSelectValueAccessor,
  DropdownButtonComponent,
  DropdownMenuComponent,
  DynamicComponent,
  FixedMaterialTabStripComponent,
  FocusActivableItemDirective,
  FocusItemDirective,
  FocusListDirective,
  FocusableDirective,
  FocusTrapComponent,
  //GlyphComponent,
  HighlightedTextComponent,
  HighlightedValueComponent,
  KeyboardOnlyFocusIndicatorDirective,
  LowerBoundValidator,
  MaterialAutoSuggestInputComponent,
  MaterialButtonComponent,
  MaterialCalendarPickerComponent,
  MaterialCheckboxComponent,
  MaterialChipComponent,
  MaterialChipsComponent,
  MaterialDatepickerComponent,
  MaterialDateRangePickerComponent,
  MaterialDateTimePickerComponent,
  MaterialDialogComponent,
  MaterialDropdownSelectComponent,
  MaterialExpansionPanel,
  MaterialExpansionPanelAutoDismiss,
  MaterialExpansionPanelSet,
  MaterialFabComponent,
  MaterialFabMenuComponent,
  MaterialIconComponent,
  MaterialIconTooltipComponent,
  MaterialInkTooltipComponent,
  MaterialInputComponent,
  MaterialInputDefaultValueAccessor,
  MenuItemAffixListComponent,
  MenuItemGroupsComponent,
  MaterialListComponent,
  MaterialListItemComponent,
  MaterialMenuComponent,
  MaterialMonthPickerComponent,
  MaterialMultilineInputComponent,
  materialNumberInputDirectives,
  MaterialPaperTooltipComponent,
  MaterialPercentInputDirective,
  MaterialPersistentDrawerDirective,
  MaterialPopupComponent,
  MaterialProgressComponent,
  MaterialRadioComponent,
  MaterialRadioGroupComponent,
  MaterialRippleComponent,
  MaterialSelectComponent,
  MaterialSelectDropdownItemComponent,
  MaterialSelectItemComponent,
  MaterialSelectSearchboxComponent,
  MaterialSliderComponent,
  MaterialSpinnerComponent,
  MaterialStackableDrawerComponent,
  MaterialStepperBackButtonTextDirective,
  MaterialStepperComponent,
  MaterialTabComponent,
  MaterialTabPanelComponent,
  MaterialTimePickerComponent,
  MaterialTemporaryDrawerComponent,
  MaterialTreeComponent,
  MaterialTreeDropdownComponent,
  MaterialToggleComponent,
  MaterialTooltipDirective,
  MaterialTooltipSourceDirective,
  MaterialTooltipTargetDirective,
  MaterialYesNoButtonsComponent,
  MenuPopupComponent,
  //MenuRootDirective,
  MultiDropdownSelectValueAccessor,
  ModalComponent,
  NgModel,
  PositiveNumValidator,
  PopupSourceDirective,
  ReorderItemDirective,
  ReorderListComponent,
  ScoreboardComponent,
  ScorecardComponent,
  StepDirective,
  StopPropagationDirective,
  SummaryDirective,
  TabButtonComponent,
  UpperBoundValidator,
];*/

@Component(
    selector: 'my-app',
    styleUrls: ['app_component.css'],
    templateUrl: 'app_component.html',
    directives: [
      coreDirectives,
      // materialDirectives,
      formDirectives,
      routerDirectives,
      HeaderPrincipalComponent,
      FooterPrincipalComponent,
      MidiaCarouselComponent,
    ],
    // providers: <dynamic>[materialProviders],
    exports: [Routes, RoutePaths])
class AppComponent {
  final HeaderFooterService headerFooterService;

  AppComponent(this.headerFooterService);
}
