import 'package:material_ui/material_ui.dart';
import 'package:vibes_nest/constants.dart';

class CustomTextfield extends StatelessWidget {
  final IconData icon;
  final bool obscureText;
  final String hintText;

  const CustomTextfield({
    super.key,
    required this.icon,
    required this.obscureText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: TextStyle(
        color: Constants.blackColor,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(
          icon,
          color: Constants.blackColor.withValues(alpha: .3),
        ),
        hintText: hintText,
      ),
      cursorColor: Constants.blackColor.withValues(alpha: .5),
    );
  }
}
