import 'package:cinteraction_vc/layers/domain/entities/api_error.dart';
import 'package:dio/dio.dart';

class ApiErrorDto extends ApiError{

  ApiErrorDto({required super.errorCode, required super.errorMessage});

  factory ApiErrorDto.fromDioException(DioException exception) {
    if(exception.response!= null)
    {
     return ApiErrorDto(
        errorCode: exception.response?.statusCode as int,
        errorMessage: exception.response?.data['message'] as String,
      );
    }

       return ApiErrorDto(
      errorCode: 0,
      errorMessage: exception.message as String,
    );

  }




}