import 'package:flutter/material.dart';

class TextFieldCustom extends StatefulWidget {
  const TextFieldCustom(this.hintText,
      {Key? key,
      this.validator,
      this.onChange,
      this.obscureText,
      this.controller,
      this.enabled})
      : super(key: key);
  final String hintText;
  final Function(String?)? validator;
  final Function(String?)? onChange;
  final bool? obscureText;
  final TextEditingController? controller;
  final bool? enabled;
  @override
  State<TextFieldCustom> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  late bool _obscureText;
  IconData _iconData = Icons.visibility;
  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) => widget.validator?.call(value),
      onChanged: (value) => widget.onChange?.call(value),
      obscureText: _obscureText,
      controller: widget.controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        suffixIcon: (widget.obscureText ?? false)
            ? IconButton(
                icon: Icon(_iconData),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                    _iconData =
                        _obscureText ? Icons.visibility : Icons.visibility_off;
                  });
                },
              )
            : null,
        hintText: "********",
        label: Text(widget.hintText),
        labelStyle: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: Colors.grey.shade500),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Theme.of(context).primaryColor.withOpacity(0.6)),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
      ),
    );
  }
}

class TextFieldNormalCustom extends StatefulWidget {
  const TextFieldNormalCustom(this.hintText,
      {Key? key,
      required this.isRequired,
      this.validator,
      this.onChange,
      this.obscureText,
      this.controller,
      this.enabled})
      : super(key: key);
  final bool isRequired;
  final String hintText;
  final Function(String?)? validator;
  final Function(String?)? onChange;
  final bool? obscureText;
  final TextEditingController? controller;
  final bool? enabled;
  @override
  State<TextFieldNormalCustom> createState() => _TextFieldNormalCustomState();
}

class _TextFieldNormalCustomState extends State<TextFieldNormalCustom> {
  late bool _obscureText;
  IconData _iconData = Icons.visibility;
  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) => widget.validator?.call(value),
      onChanged: (value) => widget.onChange?.call(value),
      obscureText: _obscureText,
      controller: widget.controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        label: Row(
          children: [
            if (widget.isRequired)
              Text(
                '※',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.red),
              ),
            Text(widget.hintText)
          ],
        ),
        suffixIcon: (widget.obscureText ?? false)
            ? IconButton(
                icon: Icon(_iconData),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                    _iconData =
                        _obscureText ? Icons.visibility : Icons.visibility_off;
                  });
                },
              )
            : null,
        hintText: widget.hintText,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Theme.of(context).primaryColor.withOpacity(0.6)),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
      ),
    );
  }
}
// decoration: InputDecoration(
//             suffixIcon: (widget.obscureText ?? false)
//                 ? IconButton(
//                     icon: Icon(_iconData),
//                     onPressed: () {
//                       setState(() {
//                         _obscureText = !_obscureText;
//                         _iconData = _obscureText
//                             ? Icons.visibility
//                             : Icons.visibility_off;
//                       });
//                     },
//                   )
//                 : null,
//             contentPadding: const EdgeInsets.all(8),
//             hintText: widget.hintText,
//             border:
//                 OutlineInputBorder(borderRadius: BorderRadius.circular(12))),