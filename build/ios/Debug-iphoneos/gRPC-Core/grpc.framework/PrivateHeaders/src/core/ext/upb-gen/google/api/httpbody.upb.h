/* This file was generated by upb_generator from the input file:
 *
 *     google/api/httpbody.proto
 *
 * Do not edit -- your changes will be discarded when the file is
 * regenerated. */

#ifndef GOOGLE_API_HTTPBODY_PROTO_UPB_H_
#define GOOGLE_API_HTTPBODY_PROTO_UPB_H_

#include "upb/generated_code_support.h"

#include "google/api/httpbody.upb_minitable.h"

#include "google/protobuf/any.upb_minitable.h"

// Must be last.
#include "upb/port/def.inc"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct google_api_HttpBody google_api_HttpBody;
struct google_protobuf_Any;



/* google.api.HttpBody */

UPB_INLINE google_api_HttpBody* google_api_HttpBody_new(upb_Arena* arena) {
  return (google_api_HttpBody*)_upb_Message_New(&google__api__HttpBody_msg_init, arena);
}
UPB_INLINE google_api_HttpBody* google_api_HttpBody_parse(const char* buf, size_t size, upb_Arena* arena) {
  google_api_HttpBody* ret = google_api_HttpBody_new(arena);
  if (!ret) return NULL;
  if (upb_Decode(buf, size, ret, &google__api__HttpBody_msg_init, NULL, 0, arena) != kUpb_DecodeStatus_Ok) {
    return NULL;
  }
  return ret;
}
UPB_INLINE google_api_HttpBody* google_api_HttpBody_parse_ex(const char* buf, size_t size,
                           const upb_ExtensionRegistry* extreg,
                           int options, upb_Arena* arena) {
  google_api_HttpBody* ret = google_api_HttpBody_new(arena);
  if (!ret) return NULL;
  if (upb_Decode(buf, size, ret, &google__api__HttpBody_msg_init, extreg, options, arena) !=
      kUpb_DecodeStatus_Ok) {
    return NULL;
  }
  return ret;
}
UPB_INLINE char* google_api_HttpBody_serialize(const google_api_HttpBody* msg, upb_Arena* arena, size_t* len) {
  char* ptr;
  (void)upb_Encode(msg, &google__api__HttpBody_msg_init, 0, arena, &ptr, len);
  return ptr;
}
UPB_INLINE char* google_api_HttpBody_serialize_ex(const google_api_HttpBody* msg, int options,
                                 upb_Arena* arena, size_t* len) {
  char* ptr;
  (void)upb_Encode(msg, &google__api__HttpBody_msg_init, options, arena, &ptr, len);
  return ptr;
}
UPB_INLINE void google_api_HttpBody_clear_content_type(google_api_HttpBody* msg) {
  const upb_MiniTableField field = {1, UPB_SIZE(4, 0), 0, kUpb_NoSub, 9, (int)kUpb_FieldMode_Scalar | ((int)kUpb_FieldRep_StringView << kUpb_FieldRep_Shift)};
  _upb_Message_ClearNonExtensionField(msg, &field);
}
UPB_INLINE upb_StringView google_api_HttpBody_content_type(const google_api_HttpBody* msg) {
  upb_StringView default_val = upb_StringView_FromString("");
  upb_StringView ret;
  const upb_MiniTableField field = {1, UPB_SIZE(4, 0), 0, kUpb_NoSub, 9, (int)kUpb_FieldMode_Scalar | ((int)kUpb_FieldRep_StringView << kUpb_FieldRep_Shift)};
  _upb_Message_GetNonExtensionField(msg, &field, &default_val, &ret);
  return ret;
}
UPB_INLINE void google_api_HttpBody_clear_data(google_api_HttpBody* msg) {
  const upb_MiniTableField field = {2, UPB_SIZE(12, 16), 0, kUpb_NoSub, 12, (int)kUpb_FieldMode_Scalar | ((int)kUpb_FieldRep_StringView << kUpb_FieldRep_Shift)};
  _upb_Message_ClearNonExtensionField(msg, &field);
}
UPB_INLINE upb_StringView google_api_HttpBody_data(const google_api_HttpBody* msg) {
  upb_StringView default_val = upb_StringView_FromString("");
  upb_StringView ret;
  const upb_MiniTableField field = {2, UPB_SIZE(12, 16), 0, kUpb_NoSub, 12, (int)kUpb_FieldMode_Scalar | ((int)kUpb_FieldRep_StringView << kUpb_FieldRep_Shift)};
  _upb_Message_GetNonExtensionField(msg, &field, &default_val, &ret);
  return ret;
}
UPB_INLINE void google_api_HttpBody_clear_extensions(google_api_HttpBody* msg) {
  const upb_MiniTableField field = {3, UPB_SIZE(0, 32), 0, 0, 11, (int)kUpb_FieldMode_Array | ((int)UPB_SIZE(kUpb_FieldRep_4Byte, kUpb_FieldRep_8Byte) << kUpb_FieldRep_Shift)};
  _upb_Message_ClearNonExtensionField(msg, &field);
}
UPB_INLINE const struct google_protobuf_Any* const* google_api_HttpBody_extensions(const google_api_HttpBody* msg, size_t* size) {
  const upb_MiniTableField field = {3, UPB_SIZE(0, 32), 0, 0, 11, (int)kUpb_FieldMode_Array | ((int)UPB_SIZE(kUpb_FieldRep_4Byte, kUpb_FieldRep_8Byte) << kUpb_FieldRep_Shift)};
  const upb_Array* arr = upb_Message_GetArray(msg, &field);
  if (arr) {
    if (size) *size = arr->size;
    return (const struct google_protobuf_Any* const*)_upb_array_constptr(arr);
  } else {
    if (size) *size = 0;
    return NULL;
  }
}
UPB_INLINE const upb_Array* _google_api_HttpBody_extensions_upb_array(const google_api_HttpBody* msg, size_t* size) {
  const upb_MiniTableField field = {3, UPB_SIZE(0, 32), 0, 0, 11, (int)kUpb_FieldMode_Array | ((int)UPB_SIZE(kUpb_FieldRep_4Byte, kUpb_FieldRep_8Byte) << kUpb_FieldRep_Shift)};
  const upb_Array* arr = upb_Message_GetArray(msg, &field);
  if (size) {
    *size = arr ? arr->size : 0;
  }
  return arr;
}
UPB_INLINE upb_Array* _google_api_HttpBody_extensions_mutable_upb_array(const google_api_HttpBody* msg, size_t* size, upb_Arena* arena) {
  const upb_MiniTableField field = {3, UPB_SIZE(0, 32), 0, 0, 11, (int)kUpb_FieldMode_Array | ((int)UPB_SIZE(kUpb_FieldRep_4Byte, kUpb_FieldRep_8Byte) << kUpb_FieldRep_Shift)};
  upb_Array* arr = upb_Message_GetOrCreateMutableArray(
      (upb_Message*)msg, &field, arena);
  if (size) {
    *size = arr ? arr->size : 0;
  }
  return arr;
}
UPB_INLINE bool google_api_HttpBody_has_extensions(const google_api_HttpBody* msg) {
  size_t size;
  google_api_HttpBody_extensions(msg, &size);
  return size != 0;
}

UPB_INLINE void google_api_HttpBody_set_content_type(google_api_HttpBody *msg, upb_StringView value) {
  const upb_MiniTableField field = {1, UPB_SIZE(4, 0), 0, kUpb_NoSub, 9, (int)kUpb_FieldMode_Scalar | ((int)kUpb_FieldRep_StringView << kUpb_FieldRep_Shift)};
  _upb_Message_SetNonExtensionField(msg, &field, &value);
}
UPB_INLINE void google_api_HttpBody_set_data(google_api_HttpBody *msg, upb_StringView value) {
  const upb_MiniTableField field = {2, UPB_SIZE(12, 16), 0, kUpb_NoSub, 12, (int)kUpb_FieldMode_Scalar | ((int)kUpb_FieldRep_StringView << kUpb_FieldRep_Shift)};
  _upb_Message_SetNonExtensionField(msg, &field, &value);
}
UPB_INLINE struct google_protobuf_Any** google_api_HttpBody_mutable_extensions(google_api_HttpBody* msg, size_t* size) {
  upb_MiniTableField field = {3, UPB_SIZE(0, 32), 0, 0, 11, (int)kUpb_FieldMode_Array | ((int)UPB_SIZE(kUpb_FieldRep_4Byte, kUpb_FieldRep_8Byte) << kUpb_FieldRep_Shift)};
  upb_Array* arr = upb_Message_GetMutableArray(msg, &field);
  if (arr) {
    if (size) *size = arr->size;
    return (struct google_protobuf_Any**)_upb_array_ptr(arr);
  } else {
    if (size) *size = 0;
    return NULL;
  }
}
UPB_INLINE struct google_protobuf_Any** google_api_HttpBody_resize_extensions(google_api_HttpBody* msg, size_t size, upb_Arena* arena) {
  upb_MiniTableField field = {3, UPB_SIZE(0, 32), 0, 0, 11, (int)kUpb_FieldMode_Array | ((int)UPB_SIZE(kUpb_FieldRep_4Byte, kUpb_FieldRep_8Byte) << kUpb_FieldRep_Shift)};
  return (struct google_protobuf_Any**)upb_Message_ResizeArrayUninitialized(msg, &field, size, arena);
}
UPB_INLINE struct google_protobuf_Any* google_api_HttpBody_add_extensions(google_api_HttpBody* msg, upb_Arena* arena) {
  upb_MiniTableField field = {3, UPB_SIZE(0, 32), 0, 0, 11, (int)kUpb_FieldMode_Array | ((int)UPB_SIZE(kUpb_FieldRep_4Byte, kUpb_FieldRep_8Byte) << kUpb_FieldRep_Shift)};
  upb_Array* arr = upb_Message_GetOrCreateMutableArray(msg, &field, arena);
  if (!arr || !_upb_Array_ResizeUninitialized(arr, arr->size + 1, arena)) {
    return NULL;
  }
  struct google_protobuf_Any* sub = (struct google_protobuf_Any*)_upb_Message_New(&google__protobuf__Any_msg_init, arena);
  if (!arr || !sub) return NULL;
  _upb_Array_Set(arr, arr->size - 1, &sub, sizeof(sub));
  return sub;
}

#ifdef __cplusplus
}  /* extern "C" */
#endif

#include "upb/port/undef.inc"

#endif  /* GOOGLE_API_HTTPBODY_PROTO_UPB_H_ */
