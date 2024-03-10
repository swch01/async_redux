// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/async_redux

import 'package:async_redux/async_redux.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import "package:meta/meta.dart";

/// Extends the [UserException] to add more features.
///
/// The [AdvancedUserException] is not supposed to be instantiated directly. Instead, use
/// the [addCallbacks], [addCause] and [addProps] extension methods in the [UserException]:
///
/// ```dart
/// UserException(message, code: code, reason: reason)
///    .addCallbacks(onOk: onOk, onCancel: onCancel)
///    .addCause(cause)
///    .addProps(props);
/// ```
///
/// Example:
///
/// ```dart
/// throw UserException('Invalid number', reason: 'Must be less than 42')
///    .addCallbacks(onOk: () => print('OK'), onCancel: () => print('CANCEL'))
///    .addCause(FormatException('Invalid input'))
///    .addProps({'number': 42}));
/// ```
///
/// When the exception is shown to the user in the [UserExceptionDialog], if
/// callbacks [onOk] and [onCancel] are defined, the dialog will have OK and CANCEL buttons,
/// and the callbacks will be called when the user taps them.
///
/// The [hardCause] is some error which caused the [UserException].
///
/// The [props] are any key-value pair properties you'd like to add to the exception.
///
@immutable
class AdvancedUserException extends UserException {
  //

  /// Callback to be called after the user views the error and taps OK.
  final VoidCallback? onOk;

  /// Callback to be called after the user views the error and taps CANCEL.
  final VoidCallback? onCancel;

  /// The hard cause is some error which caused the [UserException], but that is not
  /// a [UserException] itself. For example: `int.parse('a')` throws a `FormatException`.
  /// Then: `throw UserException('Invalid number').addCause(FormatException('Invalid input'))`.
  /// will have the `FormatException` as the hard cause. Note: If a [UserException] is
  /// passed as the hard cause, it will be added with [addCause], and will not become the
  /// hard cause. In other words, a [UserException] will never be a hard cause.
  final Object? hardCause;

  /// The properties added to the exception, if any.
  /// They are an immutable-map of type [IMap], of key-value pairs.
  /// To read the properties, use the `[]` operator, like this:
  /// ```dart
  /// var value = exception.props['key'];
  /// ```
  /// If the key does not exist, it will return `null`.
  ///
  final IMap<String, dynamic> props;

  /// Instead of using this constructor directly, prefer doing:
  ///
  /// ```dart
  /// throw UserException('Invalid number', reason: 'Must be less than 42')
  ///    .addCallbacks(onOk: () => print('OK'), onCancel: () => print('CANCEL'))
  ///    .addCause(FormatException('Invalid input'))
  ///    .addProps({'number': 42}));
  /// ```
  ///
  /// This constructor is public only so that you can subclass [AdvancedUserException].
  ///
  const AdvancedUserException(
    super.message, {
    required super.reason,
    required super.code,
    required this.onOk,
    required this.onCancel,
    required this.hardCause,
    this.props = const IMapConst<String, dynamic>({}),
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is AdvancedUserException &&
          runtimeType == other.runtimeType &&
          onOk == other.onOk &&
          onCancel == other.onCancel &&
          hardCause == other.hardCause;

  @override
  int get hashCode => super.hashCode ^ onOk.hashCode ^ onCancel.hashCode ^ hardCause.hashCode;

  /// Returns a new [UserException], copied from the current one, but adding the given [reason].
  /// Note the added [reason] won't replace the original reason, but will be added to it.
  @useResult
  @mustBeOverridden
  @override
  UserException addReason(String? reason) {
    //
    IMap;
    UserException exception = super.addReason(reason);

    return AdvancedUserException(
      exception.message,
      reason: exception.reason,
      code: exception.code,
      onOk: onOk,
      onCancel: onCancel,
      hardCause: hardCause,
      props: props,
    );
  }

  /// Returns a new [UserException], by merging the current one with the given [userException].
  /// This simply means the given [userException] will be used as part of the [reason] of the
  /// current one.
  @useResult
  @mustBeOverridden
  @override
  UserException mergedWith(UserException? userException) {
    //
    UserException exception = super.mergedWith(userException);

    return AdvancedUserException(
      exception.message,
      reason: exception.reason,
      code: exception.code,
      onOk: onOk,
      onCancel: onCancel,
      hardCause: hardCause,
      props: props,
    );
  }
}

extension UserExceptionAdvancedExtension on UserException {
  //
  /// The `onOk` callback of the exception, or `null` if it was not defined.
  VoidCallback? get onOk {
    var exception = this;
    return (exception is AdvancedUserException) ? exception.onOk : null;
  }

  /// The `onCancel` callback of the exception, or `null` if it was not defined.
  VoidCallback? get onCancel {
    var exception = this;
    return (exception is AdvancedUserException) ? exception.onCancel : null;
  }

  /// The hard cause is some error which caused the [UserException], but that is not
  /// a [UserException] itself. For example: `int.parse('a')` throws a `FormatException`.
  /// Then: `throw UserException('Invalid number').addCause(FormatException('Invalid input'))`.
  /// will have the `FormatException` as the hard cause. Note: If a [UserException] is
  /// passed as the hard cause, it will be added with [addCause], and will not become the
  /// hard cause. In other words, a [UserException] will never be a hard cause.
  Object? get hardCause {
    var exception = this;
    return (exception is AdvancedUserException) ? exception.hardCause : null;
  }

  /// The properties added to the exception, if any.
  /// They are an immutable-map of type [IMap], of key-value pairs.
  /// To read the properties, use the `[]` operator, like this:
  /// ```dart
  /// var value = exception.props['key'];
  /// ```
  /// If the key does not exist, it will return `null`.
  ///
  IMap<String, dynamic> get props {
    var exception = this;
    return (exception is AdvancedUserException)
        ? exception.props
        : const IMapConst<String, dynamic>({});
  }

  /// Returns a [UserException] from the current one, by adding the given [cause].
  /// Note the added [cause] won't replace the original cause, but will be added to it.
  ///
  /// If the added [cause] is a `null`, it will return the current exception, unchanged.
  ///
  /// If the added [cause] is a [String], the [addReason] method will be used to
  /// return the new exception.
  ///
  /// If the added [cause] is a [UserException], the [mergedWith] method will be used to
  /// return the new exception.
  ///
  /// If the added [cause] is any other type, including any other error types, it will be
  /// set as the property [hardCause] of the exception. The hard cause is meant to be some
  /// error which caused the [UserException], but that is not a [UserException] itself.
  /// For example, if `int.parse('a')` throws a `FormatException`, then
  /// `throw UserException('Invalid number').addCause(FormatException('Invalid input'))`.
  /// will set the `FormatException` as the hard cause.
  ///
  @useResult
  UserException addCause(Object? cause) {
    //
    if (cause == null) {
      return this;
    }
    //
    else if (cause is String) {
      return addReason(cause);
    }
    //
    else if (cause is UserException) {
      return mergedWith(cause);
    }
    //
    // Now we're going to set the hard cause.
    else {
      return AdvancedUserException(
        message,
        reason: reason,
        code: code,
        onOk: onOk,
        onCancel: onCancel,
        props: props,
        hardCause: cause, // We discard the old hard cause, if any.
      );
    }
  }

  /// Adds callbacks to the [UserException].
  ///
  /// This method is used to add `onOk` and `onCancel` callbacks to the [UserException].
  ///
  /// The [onOk] callback will be called when the user taps OK in the error dialog.
  /// The [onCancel] callback will be called when the user taps CANCEL in the error dialog.
  ///
  /// If the exception already had callbacks, the new callbacks will be merged with the old ones,
  /// and the old callbacks will be called before the new ones.
  ///
  @useResult
  UserException addCallbacks({
    VoidCallback? onOk,
    VoidCallback? onCancel,
  }) {
    var exception = this;

    if (exception is AdvancedUserException) {
      VoidCallback? _onOk;
      VoidCallback? _onCancel;

      if (exception.onOk == null)
        _onOk = onOk;
      else
        _onOk = () {
          exception.onOk?.call();
          onOk?.call();
        };

      if (exception.onCancel == null)
        _onCancel = onCancel;
      else
        _onCancel = () {
          exception.onCancel?.call();
          onCancel?.call();
        };

      return AdvancedUserException(
        message,
        reason: reason,
        code: code,
        onOk: _onOk,
        onCancel: _onCancel,
        props: exception.props,
        hardCause: exception.hardCause,
      );
    }
    //
    else
      return AdvancedUserException(
        message,
        reason: reason,
        code: code,
        onOk: onOk,
        onCancel: onCancel,
        props: const IMapConst<String, dynamic>({}),
        hardCause: null,
      );
  }

  /// Adds [moreProps] to the properties of the [UserException].
  /// If the exception already had [props], the new [moreProps] will be merged with those.
  ///
  @useResult
  UserException addProps(Map<String, dynamic>? moreProps) {
    if (moreProps == null) return this;

    var exception = this;

    if (exception is AdvancedUserException)
      return AdvancedUserException(
        message,
        reason: reason,
        code: code,
        onOk: exception.onOk,
        onCancel: exception.onCancel,
        props: exception.props.addMap(moreProps),
        hardCause: exception.hardCause,
      );
    //
    else
      return AdvancedUserException(
        message,
        reason: reason,
        code: code,
        onOk: null,
        onCancel: null,
        props: moreProps.lock,
        hardCause: null,
      );
  }
}

/// If you want the [UserExceptionDialog] to display some [UserException],
/// you must throw the exception from inside an action's `before` or `reduce`
/// methods.
///
/// However, sometimes you need to create some callback that throws
/// an [UserException]. If this callback is be called outside of an action,
/// the dialog will not display the exception. To solve this, the callback
/// should not throw an exception, but instead call the [UserExceptionAction],
/// which will then simply throw the exception in its `reduce` method.
///
class UserExceptionAction<St> extends ReduxAction<St> {
  final UserException exception;

  UserExceptionAction(
    /// Some message shown to the user.
    /// Example: `dispatch(UserExceptionAction('Invalid number'))`
    String? message, {
    //
    /// Optionally, instead of [message] we may provide a numeric [code].
    /// This code may have an associated message which is set in the client.
    /// Example: `dispatch(UserExceptionAction('', code: 12))`
    int? code,

    /// Another message which is the reason of the user-exception.
    /// Example: `dispatch(UserExceptionAction('Invalid number', reason: 'Must be less than 42'))`
    String? reason,

    /// Callback to be called after the user views the error and taps OK.
    VoidCallback? onOk,

    /// Callback to be called after the user views the error and taps CANCEL.
    VoidCallback? onCancel,

    /// Adds the given `cause` to the exception.
    /// * If the added `cause` is a `String`, the `addReason` method will be used to
    /// create the exception.
    /// * If the added `cause` is a `UserException`, the `mergedWith` method will
    /// be used to create the exception.
    /// * If the added `cause` is any other type, including any other error types, it will be
    /// set as the property `hardCause` of the exception. The hard cause is meant to be some
    /// error which caused the `UserException`, but that is not a `UserException` itself.
    /// For example: `dispatch(UserException('Invalid number', cause: FormatException('Invalid input'))`.
    /// will set the `FormatException` as the hard cause.
    Object? cause,

    /// Any key-value pair properties you'd like to add to the exception.
    /// For example: `props: {'name': 'John', 'age': 42}`
    Map<String, dynamic>? props,
    //
  }) : this.from(
          UserException(message, reason: reason, code: code).addCause(cause).addProps(props),
        );

  UserExceptionAction.from(this.exception);

  @override
  Future<St> reduce() async => throw exception;
}