unit Tensorflow.Utils;
{$REGION 'Licence'}
(*****************************************************************************
   Copyright 2018 The TensorFlow.NET Authors. All Rights Reserved.
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
       http://www.apache.org/licenses/LICENSE-2.0
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
******************************************************************************)
{$ENDREGION}

interface
    uses System.SysUtils,
         System.TypInfo,
         System.Variants,
         System.Rtti,
         System.Generics.Collections,
         IdHTTP, IdSSLOpenSSL,

         Spring,
         Spring.Collections,

         Spring.Collections.Enumerable,

         TensorFlow.DApi,
         TensorFlow.DApiBase,
         TF4D.Core.CApi,
         TensorFlow.Slice,
         Tensorflow.Tensor,
         NumPy.NDArray,
         Numpy.Axis,

         TensorFlow.Proto;

type
  // Classe generica TTuple
  TTuple<T1, T2> = class
  private
    FFirst: T1;
    FSecond: T2;
  public
    constructor Create(const AFirst: T1; const ASecond: T2);
    property First: T1 read FFirst write FFirst;
    property Second: T2 read FSecond write FSecond;
  end;

  TValueHelp = record Helper for TValue

    public
      class operator Implicit(Const Value: Uint8):TValue;
      class operator Implicit(Const Value: Int8):TValue;
      //
      class operator Implicit(const Value: TNDArray): TValue;
      class operator Implicit(const Value: TValue): TNDArray;
      class operator Implicit(const Value: NDArray): TValue;
      class operator Implicit(const Value: TValue): NDArray;
      //
      class operator Implicit(const Value: TTensor): TValue;
      class operator Implicit(const Value: TValue): TTensor;
      class operator Implicit(const Value: TFTensor): TValue;
      class operator Implicit(const Value: TValue): TFTensor;
      //
      class operator Implicit(const Value: TArray<TFTensor>): TValue;
      class operator Implicit(const Value: TArray<Integer>): TValue;
      class operator Implicit(const Value: TArray<Int64>): TValue;
      class operator Implicit(const Value: TArray<Single>): TValue;
      class operator Implicit(const Value: TArray<Byte>): TValue;
      class operator Implicit(const Value: TArray<String>): TValue;
      class operator Implicit(const Value: TF_DataType): TValue;
      class operator Implicit(const Value: TArray< TArray<Integer> >): TValue;
      class operator Implicit(const Value: TArray< TArray<Single> >): TValue;
      class operator Implicit(const Value: TArray< TArray<TArray<Integer>> >): TValue;
      class operator Implicit(const Value: TArray< TArray<Double> >): TValue;

  end;

 Tdtypes = record
  private

   public

       const cbool       : TF_DataType  = TF_DataType.TF_BOOL;
       const constcint8  : TF_DataType  = TF_DataType.TF_INT8;
       const cint32      : TF_DataType  = TF_DataType.TF_INT32;
       const cint64      : TF_DataType  = TF_DataType.TF_INT64;
       const cuint8      : TF_DataType  = TF_DataType.TF_UINT8;
       const cuint32     : TF_DataType  = TF_DataType.TF_UINT32;
       const cuint64     : TF_DataType  = TF_DataType.TF_UINT64;
       const cfloat32    : TF_DataType  = TF_DataType.TF_FLOAT; // is that float32?
       const cfloat16    : TF_DataType  = TF_DataType.TF_HALF;
       const cfloat64    : TF_DataType  = TF_DataType.TF_DOUBLE;
       const ccomplex    : TF_DataType  = TF_DataType.TF_COMPLEX;
       const ccomplex64  : TF_DataType  = TF_DataType.TF_COMPLEX64;
       const ccomplex128 : TF_DataType  = TF_DataType.TF_COMPLEX128;
       const cvariant    : TF_DataType  = TF_DataType.TF_VARIANT;
       const cresource   : TF_DataType  = TF_DataType.TF_RESOURCE;
   public
       class function as_numpy_name(value: TF_DataType): string; static;
       class function as_base_dtype(value: TF_DataType): TF_DataType; overload; static;
       class function as_base_dtype(value: TDataType): TDataType;  overload; static;
       class function as_ref(value: TF_DataType): TF_DataType; static;
       class function as_tf_dtype(value: TValue): TF_DataType; overload; static;
       class function as_tf_dtype(value: PTypeInfo): TF_DataType; overload;static;
       class function as_tf_dtype(value: TDataType): TF_DataType; overload;static;
       class function as_tf_dtype_fromName(value: string): TF_DataType; static;
       class function get_datatype_size(tipo: TF_DataType): Integer; static;
       class function as_datatype_enum(value: TF_DataType): TDataType; static;
       class function ToIntArray(value: TArray<TF_DataType>): TArray<Integer>; static;
       class function is_integer(tipo: TF_DataType ): Boolean; static;
       class function is_floating(tipo: TF_DataType ): Boolean;static;
       class function is_complex(tipo: TF_DataType): Boolean; static;
       class function real_dtype(tipo: TF_DataType): TF_DataType; static;
       class function is_value_dtype(tipo: TF_DataType): Boolean; static;
       class function is_ref_dtype(tipo: TF_DataType ): Boolean; static;
       class function min(tipo: TF_DataType ): Int64; static;
       class function max(tipo: TF_DataType ): Int64; static;
       class function ToString(tipo: TF_DataType): string; static ;

       /// <summary>
       ///
       /// </summary>
       /// <param name="type"></param>
       /// <returns><see cref="System.Type"/> equivalent to <paramref name="type"/>, if none exists, returns null.</returns>
       class function as_system_dtype(tipo: TF_DataType): PTypeInfo; static;
 end;

 TSorted = class
   public
      class function Sort<T,T1>(dict_: TDictionary<T, T1> ): TEnumerable<T>;
 end;

 nest = class
  private
    class function is_Mapping<T>(arg: T): Boolean; static;
    class function SequenceLike<T>    (instance: T; args: TArray<TObject>): TObject;   overload;
    class function SequenceLike<Tk,Tv>(instance: TDictionary<Tk,Tv>; args: TArray<Tk>): TObject;  overload;
    class function _packed_nest_with_indices<T>(structure : T; flat: TList<TObject>; index: Integer): Tuple<Integer, TList<TObject>> ;
    class function _yield_value<T>(Iter: T): TArray<T>; static;

   public
      class function Flatten<T>(structure: TValue):  TList<T>; overload;
      class procedure _flatten_recursive<T>(obj: TValue; list: TList<T>); static;

      class function map_structure<T>(func: TFunc<T, TFTensor>; structure: TValue) : TFTensor;
      /// <summary>
      /// Returns a sorted list of the dict keys, with error if keys not sortable.
      /// </summary>
      class function _sorted<Tk,Tv>(dict_:TDictionary<Tk, Tv>): TArray<Tk>;

      class function is_Sequence<T>(arg: T): Boolean; static;
      /// <summary>
      /// Returns a given flattened sequence packed into a given structure.
      /// If `structure` is a scalar, `flat_sequence` must be a single-element list;
      /// in this case the return value is `flat_sequence[0]`.
      ///
      /// If `structure` is or contains a dict instance, the keys will be sorted to
      /// pack the flat sequence in deterministic order. This is true also for
      /// `OrderedDict` instances: their sequence order is ignored, the sorting order of
      /// keys is used instead. The same convention is followed in `flatten`.
      /// This correctly repacks dicts and `OrderedDict`s after they have been
      /// flattened, and also allows flattening an `OrderedDict` and then repacking it
      /// back using a corresponding plain dict, or vice-versa.
      /// Dictionaries with non-sortable keys cannot be flattened.
      /// </summary>
      /// <param name="structure">
      /// Nested structure, whose structure is given by nested lists,
      /// tuples, and dicts. Note: numpy arrays and strings are considered
      /// scalars.
      /// </param>
      /// <param name="flat_sequence"> flat sequence to pack.</param>
      /// <returns> `flat_sequence` converted to have the same recursive structure as
      /// `structure`.
      /// </returns>
      class function pack_sequence_as<T>(structure: T; flat_sequence: TEnumerable<TObject>; expand_composites: Boolean = false): TObject;
 end;

 TUtils = class
  private
    class function ChangeType(x: TValue; new_system_dtype: PTypeInfo): TValue;
    class function ArrayToArrayTipo<T>(a: Tarray<T>; toTipo: PTypeInfo): TArray<Integer>;
    class function _ConstantValue(tensor: TFTensor; partial: Boolean): TNDArray;

   public
      class function MakeNdarray(tensor: TTensorProto): TNDArray; static;

      class function SequenceEqual<T>(const v1,v2: TArray<T>): boolean;
      class function IsInstance(v: TValue; t : PTypeInfo):Boolean; overload;
      class function IsInstance<T>(tipo1 : T; Tipo2: PTypeInfo): boolean; overload;
      class function IsInstance<T,T1,T2>(tipo1 : T; Tipo2: Tuple<T1,T2>): boolean;  overload;
      class function IsInstance<T,T1,T2,T3>(tipo1 : T; Tipo2: Tuple<T1,T2,T3>): boolean; overload;


      class procedure tf_with<T>(py: T; action: TProc<T>); overload;
      class function tf_with<TIn, TOut>(py: TIn; action: TFunc<TIn, TOut>): TOut;overload;
      class function GetDataType(value: TValue): TF_DataType;
      class function GetShape(value: TValue): TFShape;overload;
      class function GetShape<T>(Tval: TArray<TArray<TArray<TArray<T>>>>): TFShape;  overload;
      class function ConvertToDict(dny: TArray<TParameter>): TDictionary<string,TValue> ;
      class function Get<Tk,TV>(dict : TDictionary<Tk,TV>; key: Tk; defaultValue: TV): TV ;
      class function SetDefault<TK, TV>(dic: TDictionary<TK, TV>; key: TK; defaultValue: TV) : TV;

      class function as_shape_proto(tshape: TFShape): TTensorShapeProto; static;
      class function as_shape<T>(dims: TArray<T>): TTensorShapeProto;
      class function shape_tensor(shape: TArray<Integer>): TFTensor; static;
      /// <summary>
      /// Create a TensorProto, invoked in graph mode
      /// </summary>
      /// <param name="values"></param>
      /// <param name="dtype"></param>
      /// <param name="shape"></param>
      /// <param name="verify_shape"></param>
      /// <param name="allow_broadcast"></param>
      /// <returns></returns>
      class function make_tensor_proto(values: TValue; var dtype : TF_DataType; shape : PTFShape; verify_shape : Boolean= false; allow_broadcast : Boolean= false) : TTensorProto;
      /// <summary>
      /// Returns the constant value of the given tensor, if efficiently calculable.
      /// </summary>
      /// <param name="tensor"></param>
      /// <param name="partial"></param>
      /// <returns></returns>
      class function constant_value(tensor: TFTensor; partial: Boolean = false): TNDArray;
      class function constant_value_as_shape(tensor: TFTensor): TFShape;
      class function ParseSlices(slices: TArray<Slice>): ParsedSliceArgs; overload;
      class function ParseSlices(start: TFTensor; stop: TFTensor = nil; step: TFTensor = nil): ParsedSliceArgs; overload;
      class function zip<T1, T2>(e1 : Enumerable<T1>; e2 : TEnumerable<T2>): Enumerable<Tuple<T1,T2>> ; overload;
      class function zip<T>(e1 : TNDArray; e2 : TNDArray; axis: PAxis = nil):  Enumerable<Tuple<T,T>> ; overload;
      class function zip<T>(e1 : TList<T>; e2 : TList<T>):  Enumerable<Tuple<T,T>> ; overload;
      class function zip<T1,T2>(e1 : TList<T1>; e2 : TList<T2>):  Enumerable<Tuple<T1,T2>> ; overload;
      class function zip<T1,T2>(e1 : TList<T1>; e2 : TArray<T2>):  Enumerable<Tuple<T1,T2>> ; overload;
      class function zip<T1,T2>(e1 : TArray<T1>; e2 : TArray<T2>):  Enumerable<Tuple<T1,T2>> ; overload;
      class function zip<T1, T2>(tu1 : Tuple<T1,T1>; tu2 : Tuple<T2,T2>):  TArray< Tuple<T1,T2> > ; overload;

      class function Reversed<T>(l1: TList<T>):TList<T>;
      class procedure difference_update<T>(l1,l2: TList<T>);
      class procedure extendleft<T>(var queue : TQueue<T>; elements: TEnumerable<T>);
      class function IsSubSet<T>(subSet: TArray<T>; source: TList<T>): Boolean;

      class function range(start, _end: Integer): Enumerable<integer>;  overload; static;
      class function range(_end: Integer): Enumerable<integer> ;  overload; static;
      class procedure DownloadAsync(url: string; dirSaveTo: string; fileName: string; showProgressInConsole: Boolean = false);
      class procedure UnzipAsync(zipFile: string; saveTo: string; showProgressInConsole: Boolean = false);
      class function  DecompressTGZ(tgzFile: string; baseDir: string; isTar: Boolean= false): Boolean;
 end;

 function GetArg(sNome: string; vVal : TValue):  TParameter;
 function sum(_enumerable: TArray<TValue>): Double;
 function all(_enumerable: TArray<TValue>): Boolean;

implementation
        uses system.Generics.Defaults, System.Classes, system.IOUtils, System.ZLib,
             Winapi.Windows,

             AbUnZper, AbUtils, AbArcTyp,

             Tensorflow,
             TensorFlow.Core,
             TensorFlow.Ops,
             TensorFlow.Operations,
             Numpy,
             Complex;

function sum(_enumerable: TArray<TValue>): Double;
begin
    var typedef : TArray<PTypeInfo>:= [ TypeInfo(Double), TypeInfo(Integer), TypeInfo(Single) ];
    var sum : Double := 0.0;
    for var e1 in _enumerable do
    begin
        if not TArray.Contains<PTypeInfo>(typedef , e1.TypeInfo) then
            raise TfException.Create('Numeric array expected');
        sum := sum  + Double(e1.AsOrdinal);
    end;
    Result := sum;
end;

function all(_enumerable: TArray<TValue>): Boolean;
begin
    for var e1 in _enumerable do
    begin
       var b : Boolean;
        if not e1.TryAsType<Boolean>(b) then
           Exit(false);
    end;
    Result := true;
end;

function GetArg(sNome: string; vVal : TValue):  TParameter;
begin
     Result.sNome := sNome;
     Result.vValue:= vVal;
end;

{ TSorted }

class function TSorted.Sort<T,T1>(dict_: TDictionary<T, T1> ): TEnumerable<T>;
begin
     var k  := dict_.Keys.ToArray;
     TArray.Sort<T>(k);
     Result := TList<T>.Create(k);
end;

{ Tdtypes }

class function Tdtypes.as_datatype_enum(value: TF_DataType): TDataType;
begin
    Result := TDataType(Ord(value)) ;
end;

class function Tdtypes.ToIntArray(value: TArray<TF_DataType>): TArray<Integer>;
begin
    Result := [];
    for var i:= 0 to Length(value)-1 do
       Result := Result + [Ord(value[i]) ] ;
end;

class function Tdtypes.ToString(tipo: TF_DataType): string;
begin
    case tipo of
      DtInvalid    :  Result := 'DtInvalid';
      TF_FLOAT     :  Result := 'TF_FLOAT';
      TF_DOUBLE    :  Result := 'TF_DOUBLE';
      TF_INT32     :  Result := 'TF_INT32';
      TF_UINT8     :  Result := 'TF_UINT8';
      TF_INT16     :  Result := 'TF_INT16';
      TF_INT8      :  Result := 'TF_INT8';
      TF_STRING    :  Result := 'TF_STRING';
      TF_COMPLEX   :  Result := 'TF_COMPLEX';
      TF_INT64     :  Result := 'TF_INT64';
      TF_BOOL      :  Result := 'TF_BOOL';
      TF_QINT8     :  Result := 'TF_QINT8';
      TF_QUINT8    :  Result := 'TF_QUINT8';
      TF_QINT32    :  Result := 'TF_QINT32';
      TF_BFLOAT16  :  Result := 'TF_BFLOAT16';
      TF_QINT16    :  Result := 'TF_QINT16';
      TF_QUINT16   :  Result := 'TF_QUINT16';
      TF_UINT16    :  Result := 'TF_UINT16';
      TF_COMPLEX128:  Result := 'TF_COMPLEX128';
      TF_HALF      :  Result := 'TF_HALF';
      TF_RESOURCE  :  Result := 'TF_RESOURCE';
      TF_VARIANT   :  Result := 'TF_VARIANT';
      TF_UINT32    :  Result := 'TF_UINT32';
      TF_UINT64    :  Result := 'TF_UINT64';

      DtFloatRef     :  Result := 'DtFloatRef';
      DtDoubleRef    :  Result := 'DtDoubleRef';
      DtInt32Ref     :  Result := 'DtInt32Ref';
      DtUint8Ref     :  Result := 'DtUint8Ref';
      DtInt16Ref     :  Result := 'DtInt16Ref';
      DtInt8Ref      :  Result := 'DtInt8Ref';
      DtStringRef    :  Result := 'DtStringRef';
      DtComplex64Ref :  Result := 'DtComplex64Ref';
      DtInt64Ref     :  Result := 'DtInt64Ref';
      DtBoolRef      :  Result := 'DtBoolRef';
      DtQint8Ref     :  Result := 'DtQint8Ref';
      DtQuint8Ref    :  Result := 'DtQuint8Ref';
      DtQint32Ref    :  Result := 'DtQint32Ref';
      DtBfloat16Ref  :  Result := 'DtBfloat16Ref';
      DtQint16Ref    :  Result := 'DtQint16Ref';
      DtQuint16Ref   :  Result := 'DtQuint16Ref';
      DtUint16Ref    :  Result := 'DtUint16Ref';
      DtComplex128Ref:  Result := 'DtComplex128Ref';
      DtHalfRef      :  Result := 'DtHalfRef';
      DtResourceRef  :  Result := 'DtResourceRef';
      DtVariantRef   :  Result := 'DtVariantRef';
      DtUint32Ref    :  Result := 'DtUint32Ref';
      DtUint64Ref    :  Result := 'DtUint64Ref';
    end;
end;

class function Tdtypes.as_base_dtype(value: TF_DataType): TF_DataType;
begin
    if Ord(value) > 100 then Result := TF_DataType(Ord(value) - 100 )
    else                     Result := value;
end;

class function Tdtypes.as_base_dtype(value: TDataType): TDataType;
begin
    if Ord(value) > 100 then Result := TDataType(Ord(value) - 100 )
    else                     Result := value;
end;

class function Tdtypes.as_ref(value: TF_DataType): TF_DataType;
begin
    if Ord(value) < 100 then Result := TF_DataType(Ord(value) + 100 )
    else                     Result := value;
end;

class function Tdtypes.as_numpy_name(value: TF_DataType): string;
begin
    case value of
        TF_DataType.TF_STRING   : Result :='string';
        TF_DataType.TF_UINT8    : Result :='uint8';
        TF_DataType.TF_INT8     : Result :='int8';
        TF_DataType.TF_UINT32   : Result :='uint32';
        TF_DataType.TF_INT32    : Result :='int32';
        TF_DataType.TF_INT16    : Result :='int16';
        TF_DataType.TF_UINT16   : Result :='uint16';
        TF_DataType.TF_UINT64   : Result :='uint64';
        TF_DataType.TF_INT64    : Result :='int64';
        TF_DataType.TF_FLOAT    : Result :='float32';
        TF_DataType.TF_DOUBLE   : Result :='float64';
        TF_DataType.TF_BOOL     : Result :='bool';
        TF_DataType.TF_RESOURCE : Result :='resource';
        TF_DataType.TF_VARIANT  : Result :='variant';
    else
        Result := TEnum.GetName<TF_DataType>( value);
    end;
end;

class function Tdtypes.as_tf_dtype_fromName(value: string): TF_DataType;
var
  dType : TF_DataType;
begin
     if      string.LowerCase(value).Contains('integer')   then dType := TF_DataType.TF_INT32
     else if string.LowerCase(value).Contains('int32')     then dType := TF_DataType.TF_INT32
     else if string.LowerCase(value).Contains('cardinal')  then dType := TF_DataType.TF_UINT32
     else if string.LowerCase(value).Contains('uint32')    then dType := TF_DataType.TF_UINT32
     else if string.LowerCase(value).Contains('int64')     then dType := TF_DataType.TF_INT64
     else if string.LowerCase(value).Contains('uint64')    then dType := TF_DataType.TF_UINT64
     else if string.LowerCase(value).Contains('word')      then dType := TF_DataType.TF_UINT16
     else if string.LowerCase(value).Contains('smallint')  then dType := TF_DataType.TF_INT16
     else if string.LowerCase(value).Contains('byte')      then dType := TF_DataType.TF_UINT8
     else if string.LowerCase(value).Contains('char')      then dType := TF_DataType.TF_UINT8
     else if string.LowerCase(value).Contains('shortint')  then dType := TF_DataType.TF_INT8
     else if string.LowerCase(value).Contains('boolean')   then dType := TF_DataType.TF_BOOL
     else if string.LowerCase(value).Contains('single')    then dType := TF_DataType.TF_FLOAT
     else if string.LowerCase(value).Contains('double')    then dType := TF_DataType.TF_DOUBLE
     else if string.LowerCase(value).Contains('Extended')  then dType := TF_DataType.TF_DOUBLE
     else if string.LowerCase(value).Contains('string')    then dType := TF_DataType.TF_STRING
     else if string.LowerCase(value).Contains('ansistring')then dType := TF_DataType.TF_STRING
     else
        dType := DTInvalid;

     Result := dType;
end;

class function Tdtypes.as_tf_dtype(value: TValue): TF_DataType;
var
  tTipo : PTypeInfo;
  dType : TF_DataType;
begin
    while value.IsArray do
       value := value.GetArrayElement(0);

     tTipo:= value.TypeInfo;

     if      tTipo = TypeInfo(integer)   then dType := TF_DataType.TF_INT32
     else if tTipo = TypeInfo(cardinal)  then dType := TF_DataType.TF_UINT32
     else if tTipo = TypeInfo(int64)     then dType := TF_DataType.TF_INT64
     else if tTipo = TypeInfo(uint64)    then dType := TF_DataType.TF_UINT64
     else if tTipo = TypeInfo(word)      then dType := TF_DataType.TF_UINT16
     else if tTipo = TypeInfo(smallint)  then dType := TF_DataType.TF_INT16
     else if tTipo = TypeInfo(byte)      then dType := TF_DataType.TF_UINT8
     else if tTipo = TypeInfo(char)      then dType := TF_DataType.TF_UINT8
     else if tTipo = TypeInfo(shortint)  then dType := TF_DataType.TF_INT8
     else if tTipo = TypeInfo(boolean)   then dType := TF_DataType.TF_BOOL
     else if tTipo = TypeInfo(single)    then dType := TF_DataType.TF_FLOAT
     else if tTipo = TypeInfo(double)    then dType := TF_DataType.TF_DOUBLE
     else if tTipo = TypeInfo(Extended)  then dType := TF_DataType.TF_DOUBLE
     else if tTipo = TypeInfo(string)    then dType := TF_DataType.TF_STRING
     else if tTipo = TypeInfo(ansistring)then dType := TF_DataType.TF_STRING

     else if tTipo.Kind = tkInteger      then dType := TF_DataType.TF_INT32
     else if tTipo.Kind = tkInt64        then dType := TF_DataType.TF_INT64
     else if tTipo.Kind = tkfloat        then dType := TF_DataType.TF_FLOAT
     else
        raise TFException.Create('Type not found');

     Result := dType;
end;

class function Tdtypes.as_tf_dtype(value: TDataType): TF_DataType;
begin
    Result := TF_DataType(value);
end;

class function Tdtypes.as_tf_dtype(value: PTypeInfo): TF_DataType;
var
  tTipo : PTypeInfo;
  dType : TF_DataType;

begin
     dType := TF_DataType.DtInvalid;

     while (value.Kind = tkDynArray) or (value.Kind = tkArray) do
       value := value^.TypeData^.DynArrElType^;

     tTipo:= value;

     if      tTipo = TypeInfo(integer)   then dType := TF_DataType.TF_INT32
     else if tTipo = TypeInfo(cardinal)  then dType := TF_DataType.TF_UINT32
     else if tTipo = TypeInfo(int64)     then dType := TF_DataType.TF_INT64
     else if tTipo = TypeInfo(uint64)    then dType := TF_DataType.TF_UINT64
     else if tTipo = TypeInfo(word)      then dType := TF_DataType.TF_UINT16
     else if tTipo = TypeInfo(smallint)  then dType := TF_DataType.TF_INT16
     else if tTipo = TypeInfo(byte)      then dType := TF_DataType.TF_UINT8
     else if tTipo = TypeInfo(char)      then dType := TF_DataType.TF_UINT8
     else if tTipo = TypeInfo(shortint)  then dType := TF_DataType.TF_INT8
     else if tTipo = TypeInfo(boolean)   then dType := TF_DataType.TF_BOOL
     else if tTipo = TypeInfo(single)    then dType := TF_DataType.TF_FLOAT
     else if tTipo = TypeInfo(double)    then dType := TF_DataType.TF_DOUBLE
     else if tTipo = TypeInfo(Extended)  then dType := TF_DataType.TF_DOUBLE
     else if tTipo = TypeInfo(string)    then dType := TF_DataType.TF_STRING
     else if tTipo = TypeInfo(ansistring)then dType := TF_DataType.TF_STRING;

     Result := dType;

end;

class function Tdtypes.as_system_dtype(tipo: TF_DataType): PTypeInfo ;
begin
    case as_base_dtype(tipo) of
        TF_DataType.TF_BOOL:   Result := TypeInfo(Boolean) ;
        TF_DataType.TF_UINT8:  Result := TypeInfo(UInt8) ;
        TF_DataType.TF_INT8:   Result := TypeInfo(Int8) ;
        TF_DataType.TF_INT64:  Result := TypeInfo(Int64) ;
        TF_DataType.TF_UINT64: Result := TypeInfo(UInt64) ;
        TF_DataType.TF_INT32:  Result := TypeInfo(Int32) ;
        TF_DataType.TF_UINT32: Result := TypeInfo(UInt32) ;
        TF_DataType.TF_INT16:  Result := TypeInfo(Int16) ;
        TF_DataType.TF_UINT16: Result := TypeInfo(UInt16) ;
        TF_DataType.TF_FLOAT:  Result := TypeInfo(Single) ;
        TF_DataType.TF_DOUBLE: Result := TypeInfo(Double) ;
        TF_DataType.TF_STRING: Result := TypeInfo(String) ;
        TF_DataType.TF_COMPLEX128,
        TF_DataType.TF_COMPLEX64:  Result := TypeInfo(TComplex) ;
        else
            raise TFException.Create('Unable to convert {type} to a system data type.');
    end;
end;

class function Tdtypes.get_datatype_size(tipo: TF_DataType) : Integer;
begin
     case as_base_dtype(tipo) of
        TF_DataType.TF_BOOL     : Result := SizeOf(Boolean);
        TF_DataType.TF_UINT8    : Result := SizeOf(UInt8);
        TF_DataType.TF_INT8     : Result := SizeOf(Int8);
        TF_DataType.TF_UINT16   : Result := SizeOf(UInt16);
        TF_DataType.TF_INT16    : Result := SizeOf(Int16);
        TF_DataType.TF_UINT32   : Result := SizeOf(UInt32);
        TF_DataType.TF_INT32    : Result := SizeOf(Int32);
        TF_DataType.TF_UINT64   : Result := SizeOf(UInt64);
        TF_DataType.TF_INT64    : Result := SizeOf(Int64);
        TF_DataType.TF_FLOAT    : Result := SizeOf(Single);
        TF_DataType.TF_DOUBLE   : Result := SizeOf(Double);
        TF_DataType.TF_STRING   : Result := 1;
    else
        raise TFException.Create('TUtils.get_datatype_size - NotImplemented');
    end;
end;

class function Tdtypes.is_complex(tipo: TF_DataType): Boolean;
begin
     Result := (tipo = TF_DataType.TF_COMPLEX) or (tipo = TF_DataType.TF_COMPLEX64) or  (tipo = TF_DataType.TF_COMPLEX128);
end;

class function Tdtypes.is_floating(tipo: TF_DataType): Boolean;
begin
     Result := (tipo = TF_DataType.TF_HALF) or (tipo = TF_DataType.TF_FLOAT) or  (tipo = TF_DataType.TF_DOUBLE);
end;

class function Tdtypes.is_integer(tipo: TF_DataType): Boolean;
begin
    Result := (tipo = TF_DataType.TF_INT8) or (tipo = TF_DataType.TF_INT16) or (tipo = TF_DataType.TF_INT32) or (tipo = TF_DataType.TF_INT64) or
              (tipo = TF_DataType.TF_UINT8) or (tipo = TF_DataType.TF_UINT16) or (tipo = TF_DataType.TF_UINT32) or (tipo = TF_DataType.TF_UINT64)
end;

class function Tdtypes.is_ref_dtype(tipo: TF_DataType): Boolean;
begin
     Result := Ord(tipo) > 100;
end;

class function Tdtypes.is_value_dtype(tipo: TF_DataType): Boolean;
begin
     Result := ((Ord(tipo) >= 1) and (Ord(tipo) <= 19)) or
               (tipo = TF_DataType.TF_UINT32) or
               (tipo = TF_DataType.TF_UINT64);
end;

class function Tdtypes.max(tipo: TF_DataType): Int64;
begin
    case tipo of
      TF_INT8:   Result := Int8.MaxValue;
      TF_INT16:  Result := Int16.MaxValue;
      TF_INT32:  Result := Int32.MaxValue;
      TF_INT64:  Result := Int64.MaxValue;
      TF_UINT8:  Result := UInt8.MaxValue;
      TF_UINT16: Result := UInt16.MaxValue;
      TF_UINT32: Result := UInt32.MaxValue;
      TF_UINT64: Result := Int64(UInt64.MaxValue);
    else
      raise Exception.Create(' Not Implemented - Tdtypes.max');
    end;
end;

class function Tdtypes.min(tipo: TF_DataType): Int64;
begin
    case tipo of
      TF_INT8:   Result := Int8.MinValue;
      TF_INT16:  Result := Int16.MinValue;
      TF_INT32:  Result := Int32.MinValue;
      TF_INT64:  Result := Int64.MinValue;
      TF_UINT8:  Result := UInt8.MinValue;
      TF_UINT16: Result := UInt16.MinValue;
      TF_UINT32: Result := UInt32.MinValue;
      TF_UINT64: Result := UInt64.MinValue;
    else
      raise Exception.Create(' Not Implemented - Tdtypes.min');
    end;
end;

class function Tdtypes.real_dtype(tipo: TF_DataType): TF_DataType;
begin
    var base_ : TF_DataType := as_base_dtype(tipo);
    if base_ = ccomplex64 then
        Exit( cfloat32)
    else if base_ = ccomplex128 then
        Exit(cfloat64)
    else
        Result := tipo;
end;

{ TUtils }

class function TUtils.Get<Tk, TV>(dict: TDictionary<Tk, TV>; key: Tk; defaultValue: TV): TV;
begin
    if dict.ContainsKey(key) then
      Exit( dict[key] );

    Result := defaultValue;
end;

class function TUtils.SetDefault<TK, TV>(dic: TDictionary<TK, TV>; key: TK; defaultValue: TV): TV;
begin
     if dic.ContainsKey(key) then
       Exit( dic[key]);

    dic.Add(key, defaultValue);
    Result := defaultValue;
end;

class function TUtils.GetDataType(value: TValue): TF_DataType;
var
  tTipo : PTypeInfo;
begin
   tTipo:= value.TypeInfo;
   Result := DtInvalid;

   case ttipo.Kind of
     tkClass,tkRecord,tkMRecord : begin
          if      string.LowerCase(string(tTipo.Name)) = 'tfshape'  then   Exit(TF_DataType.TF_INT64)
          else if string.LowerCase(string(tTipo.Name)) = 'taxis'    then   Exit(TF_DataType.TF_INT32)
          else if string.LowerCase(string(tTipo.Name)) = 'tndarray' then
          begin
             var v : TNDArray := value.AsType<TNDArray>;
             Exit(v.Dtype);
          end
          else if string.LowerCase(string(tTipo.Name)) = 'ndarray' then
          begin
             var v : NDArray := value.AsType<NDArray>;
             Exit(TNDArray(v).Dtype);
          end
          else if string.LowerCase(string(tTipo.Name)) = 'tftensor' then
          begin
             var v : TFTensor := value.AsType<TFTensor>;
             Exit(v.Dtype);
          end
          else if string.LowerCase(string(tTipo.Name)) = 'ttensor' then
          begin
             var v : TTensor := value.AsType<TTensor>;
             Exit(TFTensor(v).Dtype);
          end
          else if string.LowerCase(string(tTipo.Name)) = 'teagertensor' then
          begin
             var v : TEagerTensor := value.AsType<TEagerTensor>;
             Exit(v.Dtype);
          end
          else if string.LowerCase(string(tTipo.Name)) = 'tftensors' then
          begin
             var v : TFTensors := value.AsType<TFTensors>;
             Exit(v.First.Dtype );
          end
          else if string.LowerCase(string(tTipo.Name)) = 'refvariable' then
          begin
             var v : RefVariable := value.AsType<RefVariable>;
             Exit(v.dtype);
          end
          else if string.LowerCase(string(tTipo.Name)) = 'resourcevariable' then
          begin
             var v : ResourceVariable := value.AsType<ResourceVariable>;
             Exit(v.dtype);
          end
          else if string.LowerCase(string(tTipo.Name)) = 'tlist<tensorflow.dapi.tftensor>' then
          begin
             var v : TList<TensorFlow.DApi.TFTensor> := value.AsType< TList<TensorFlow.DApi.TFTensor> >;
             Exit(v.first.dtype);
          end;
     end;
     tkArray,tkDynArray: begin
          var cnt := value.GetArrayLength;
          if cnt < 1 then
          begin
              var ttt := value.TypeData^.DynArrElType^ ;
              Result := TDTypes.as_tf_dtype(ttt);
              if Result = DtInvalid then
                raise TFException.Create(' Array Length Error');
              Exit;
          end;
          Result := GetDataType( value.GetArrayElement(0) )
     end;
     tkInterface : begin
          if (string.LowerCase(string(tTipo.Name)) = 'refvariable') or (value.IsType<RefVariable>) then
          begin
             var v : RefVariable := value.AsType<RefVariable>;
             Exit(v.dtype);
          end
          else if (string.LowerCase(string(tTipo.Name)) = 'resourcevariable') or (value.IsType<ResourceVariable>) then
          begin
             var v : ResourceVariable := value.AsType<ResourceVariable>;
             Exit(v.dtype);
          end
          else if (string.LowerCase(string(tTipo.Name)) = 'ivariablev1') or (value.IsType<IVariableV1>) then
          begin
             var v : IVariableV1 := value.AsType<IVariableV1>;
             Exit(v.dtype);
          end  else
          begin
            raise TFException.Create('Interface not supportated. '+ tTipo.Name );
          end;
     end;
     tkPointer: begin
          if      string.LowerCase(string(tTipo.Name)) = 'paxis'   then  Exit(TF_DataType.TF_INT32)
          else if string.LowerCase(string(tTipo.Name)) = 'tfshape' then  Exit(TF_DataType.TF_INT64)
     end
   else
     Result := Tdtypes.as_tf_dtype(value);
   end;
end;

class function TUtils.GetShape(value: TValue): TFShape;
var
  tTipo : PTypeInfo;
begin
   tTipo:= value.TypeInfo;

   case ttipo.Kind of
     tkClass,tkRecord,tkMRecord : begin
          if value.IsType<TAxis>  then
          begin
              var v : TAxis:= value.AsType<TAxis>;

              if v.isScalar then Exit( TFShape.scalar );

              var vAx : TArray<Int64>; SetLength(vAx,Length(v.axis.Value));
              Result := TFShape.Create(vAx);
              Exit;
          end
          else if value.IsType<TNDArray> then
          begin
             var v : TNDArray := value.AsType<TNDArray>;
             Result := v.Shape;
             Exit;
          end
          else if value.IsType<TFTensor> then
          begin
             var v : TFTensor := value.AsType<TFTensor>;
             Result := v.Shape;
             Exit;
          end
          else if value.IsType<TFShape> then
          begin
             var v : TFShape := value.AsType<TFShape>;
             Result := TFShape.Create([v.rank]);
             Exit;
          end
     end;
   end;

   if not value.IsArray then
       Exit( TFShape.scalar );

   if value.IsArray then
   begin
       var aDim : TArray<Int64>;
       while Value.IsArray do
       begin
            aDim := aDim + [ Value.GetArrayLength ];

            if value.GetArrayLength < 1 then
              Break;

            Value := Value.GetArrayElement(0);
       end;
       Result := TFShape.Create(aDim);
   end else
   begin
       raise TFException.Create('NotImplementedException');
   end;

end;

class function TUtils.GetShape<T>(Tval: TArray<TArray<TArray<TArray<T>>>>): TFShape;
var
  aDim : TArray<Int64>;
begin
    SetLength(aDim,4);
    aDim[0] := Length(Tval);
    aDim[1] := Length(Tval[0]);
    aDim[2] := Length(Tval[0][0]);
    aDim[3] := Length(Tval[0][0][0]);

    Result := TFShape.Create(aDim)

end;

class procedure TUtils.tf_with<T>(py: T; action: TProc<T>);
var
  vVal : TValue;

begin
    var tTipo : PTypeInfo:= TypeInfo(T);

    if tTipo <> nil then
    begin
        vVal := TValue.From<T>(py) ;

        if vVal.IsType<TNameScope>  then
        begin
            var ns := vVal.AsType<TNameScope>;
            ns._Enter_;
        end
        else if vVal.IsType<TControlDependenciesController>  then
        begin
            var ns := vVal.AsType<TControlDependenciesController>;
            ns._Enter_;
        end
        else if vVal.IsType<TControlFlowContext>  then
        begin
            var ns := vVal.AsType<TControlFlowContext>;
            ns._Enter_;
        end;
    end;

    action(py);

    if tTipo <> nil then
    begin
        vVal := TValue.From<T>(py) ;

        if vVal.IsType<TNameScope>  then
        begin
            var ns := vVal.AsType<TNameScope>;
            ns._Exit_;
        end
        else if vVal.IsType<TControlDependenciesController>  then
        begin
            var ns := vVal.AsType<TControlDependenciesController>;
            ns._Exit_;
        end
        else if vVal.IsType<TControlFlowContext>  then
        begin
            var ns := vVal.AsType<TControlFlowContext>;
            ns._Exit_;
        end;

    end;

end;

class function TUtils.tf_with<TIn, TOut>(py: TIn; action: TFunc<TIn, TOut>): TOut;
var
  vVal : TValue;

begin
    var tTipo : PTypeInfo:= TypeInfo(TIn);

    if tTipo <> nil then
    begin
        vVal := TValue.From<TIn>(py) ;

        if vVal.IsType<TNameScope>  then
        begin
            var ns := vVal.AsType<TNameScope>;
            ns._Enter_;
        end
        else if vVal.IsType<TControlDependenciesController>  then
        begin
            var ns := vVal.AsType<TControlDependenciesController>;
            ns._Enter_;
        end
        else if vVal.IsType<TControlFlowContext>  then
        begin
            var ns := vVal.AsType<TControlFlowContext>;
            ns._Enter_;
        end;
    end;

    Result := action(py);

    if tTipo <> nil then
    begin
        vVal := TValue.From<TIn>(py) ;

        if vVal.IsType<TNameScope>  then
        begin
            var ns := vVal.AsType<TNameScope>;
            ns._Exit_;
        end
        else if vVal.IsType<TControlDependenciesController>  then
        begin
            var ns := vVal.AsType<TControlDependenciesController>;
            ns._Exit_;
        end
        else if vVal.IsType<TControlFlowContext>  then
        begin
            var ns := vVal.AsType<TControlFlowContext>;
            ns._Exit_;
        end;
    end;

end;

class function TUtils.ConvertToDict(dny: TArray<TParameter>): TDictionary<string,TValue> ;
var
  i : Integer;

begin
     var dictionary := TDictionary<string,TValue>.Create;

     for i := 0 to Length(dny)-1 do
     begin
         var Typ  := dny[i].vValue;
         var name : string := dny[i].sNome;


         dictionary.Add(name,Typ);
     end;


     

     Result := dictionary;

end;

class procedure TUtils.difference_update<T>(l1, l2: TList<T>);
begin
    for var el in l2 do
    begin
        if l1.Contains(el) then
            l1.Remove(el);
    end;
end;

class procedure TUtils.extendleft<T>(var queue: TQueue<T>; elements: TEnumerable<T>);
begin
    var aElements :=elements.ToArray;
    TArray.Reverse<T>(aElements);
    for var i := 0 to Length(aElements) - 1 do
        queue.Enqueue(aElements[i]);
end;

class function TUtils.ArrayToArrayTipo<T>(a : Tarray<T>; toTipo: PTypeInfo): TArray<Integer>;
var
  i : Integer;
  res : TArray<Integer>;
begin
    res := [];
    for i := 0 to Length(a) - 1 do
       res := res + [ ChangeType( TValue.From<T>(a[i]) , toTipo).AsInteger ];

    Result := res;
end;

class function TUtils.ChangeType(x: TValue; new_system_dtype: PTypeInfo): TValue;
begin
    Result := x.Cast(new_system_dtype) ;
end;

class function TUtils.range(_end: Integer): Enumerable<integer> ;
begin
     Result := TEnumerable.range(0, _end);
end;

class function TUtils.Reversed<T>(l1: TList<T>): TList<T>;
begin
    Result :=TList<T>.Create ;
    var len := l1.Count;
    for var i := len - 1 to 0 do
         Result.Add( l1[i] );
end;

class function TUtils.range(start: Integer; _end: Integer): Enumerable<integer> ;
begin
    Result := TEnumerable.range(start, _end - start);
end;

class function TUtils.zip<T1, T2>(e1 : Enumerable<T1>; e2 : TEnumerable<T2>): Enumerable<Tuple<T1,T2>> ;
begin
    var eE2 : Ienumerable<T2> := TCollections.CreateList<T2>(e2.ToArray) ;
    var r := e1.Zip<T2, Tuple<T1,T2> >( eE2,function(first:  T1; second : T2 ): Tuple<T1,T2>
                                                begin
                                                    Result := Tuple<T1,T2>.Create(first,second)
                                                end );
    Result := r;
end;

class function TUtils.zip<T1, T2>(tu1 : Tuple<T1,T1>; tu2 : Tuple<T2,T2>):  TArray< Tuple<T1,T2> > ;
begin
    var aArray : TArray< Tuple<T1,T2> > := [];
    for var i: Integer := 0 to  2 - 1 do
    begin
        if i = 0 then aArray := aArray + [ Tuple<T1,T2>.Create(tu1.Value1,tu2.Value1) ]
        else          aArray := aArray + [ Tuple<T1,T2>.Create(tu1.Value2,tu2.Value2) ]
    end;
    Result := aArray;
end;

class function TUtils.zip<T>(e1 : TNDArray; e2 : TNDArray; axis: PAxis = nil):  Enumerable<Tuple<T,T>> ;
begin
    if axis = nil then
    begin
        var a := e1.ToArray<T>();
        var b := e2.ToArray<T>();
        var aArray : TArray< Tuple<T,T> > := [];
        for var i: Integer := 0 to  Length(a)- 1 do
            aArray := aArray + [ Tuple<T,T>.Create(a[i],b[i]) ] ;
        Result := Enumerable<Tuple<T,T>>.Create(aArray);
    end else
       raise TFException.Create('Not Implemented' );
end;

class function TUtils.zip<T1, T2>(e1: TArray<T1>; e2: TArray<T2>): Enumerable<Tuple<T1, T2>>;
begin
    var aArray : TArray< Tuple<T1,T2> > := [];
    for var i: Integer := 0 to  Length(e1) - 1 do
        aArray := aArray + [ Tuple<T1,T2>.Create(e1[i],e2[i]) ] ;
    Result := Enumerable<Tuple<T1,T2>>.Create(aArray);
end;

class function TUtils.zip<T1, T2>(e1: TList<T1>; e2: TArray<T2>): Enumerable<Tuple<T1, T2>>;
begin
    var aArray : TArray< Tuple<T1,T2> > := [];
    for var i: Integer := 0 to  e1.Count- 1 do
        aArray := aArray + [ Tuple<T1,T2>.Create(e1[i],e2[i]) ] ;
    Result := Enumerable<Tuple<T1,T2>>.Create(aArray);
end;

class function TUtils.zip<T1, T2>(e1: TList<T1>; e2: TList<T2>): Enumerable<Tuple<T1, T2>>;
begin
    var aArray : TArray< Tuple<T1,T2> > := [];
    for var i: Integer := 0 to  e1.Count- 1 do
        aArray := aArray + [ Tuple<T1,T2>.Create(e1[i],e2[i]) ] ;
    Result := Enumerable<Tuple<T1,T2>>.Create(aArray);
end;

class function TUtils.zip<T>(e1 : TList<T>; e2 : TList<T>):  Enumerable<Tuple<T,T>> ;
begin
    var aArray : TArray< Tuple<T,T> > := [];
    for var i: Integer := 0 to  e1.Count- 1 do
        aArray := aArray + [ Tuple<T,T>.Create(e1[i],e2[i]) ] ;
    Result := Enumerable<Tuple<T,T>>.Create(aArray);
end;

class function TUtils.constant_value(tensor: TFTensor; partial: Boolean): TNDArray;
begin
    if tensor is TNDArray then Exit(TNDArray(tensor))
    else if tensor is TEagerTensor then Exit( tensor.numpy) ;
    var ret: TNDArray := _ConstantValue(tensor, partial);
    if not (ret = nil) then
        tensor.graph.prevent_feeding(tensor);
    Result := ret;
end;

class function TUtils.constant_value_as_shape(tensor: TFTensor): TFShape;
begin
  if tensor is TEagerTensor then
  begin
      if tensor.dtype = tf.int64_t then
      begin
          Result := TFShape.Create(tensor.ToArray<Int64>);
          exit;
      end else
      begin
          Result := TFShape.Create(tensor.ToArray<Integer>);
          Exit;
      end;
  end;
  { TODO -oMax -c : Implementare 02/12/2022 15:26:52 }
  raise Exception.Create('Implementare');
end;

class function TUtils._ConstantValue(tensor: TFTensor; partial: Boolean): TNDArray;
begin
    if tensor.op.tipo = 'Const' then
    begin
        var v  := tensor.op.get_attr('value');
        Result := MakeNdarray( v.Astype<TTensorProto> );
    end else
    begin
       Result := nil;
    end;
end;

class function TUtils.MakeNdarray(tensor: TTensorProto) : TNDArray;
begin

    var aSize : TArray<Int64> := [];
    for var i := 0 to tensor.TensorShape.Dims.Count - 1 do
     aSize := aSize + [ tensor.TensorShape.Dims[i].Size  ] ;
    var shape        := TFShape.Create(aSize);
    {$HINTS OFF}
    var num_elements := shape.size;

    var tensor_dtype := TDTypes.as_tf_dtype(tensor.Dtype);
    if (shape.ndim > 0) and (Length(tensor.TensorContent) > 0) then
    begin
        Result := np.frombuffer(tensor.TensorContent, shape, tensor_dtype);
    end
    else if (tensor.Dtype = TDataType.DT_HALF) or (tensor.Dtype = TDataType.DT_BFLOAT16) then
    begin
        Result := np.np_array(tensor.HalfVals.ToArray).reshape(shape);
    end
    else if tensor.Dtype = TDataType.DT_FLOAT then
    begin
        Result := np.np_array(tensor.FloatVals.ToArray).reshape(shape);
    end
    else if (tensor.Dtype = TDataType.DT_INT32) or (tensor.Dtype = TDataType.DT_UINT8) then
    begin
        Result := np.np_array(tensor.IntVals.ToArray).reshape(shape);
    end
    else if tensor.Dtype = TDataType.DT_INT64 then
    begin
        Result := np.np_array(tensor.Int64Vals.ToArray).reshape(shape);
    end
    else if tensor.Dtype = TDataType.DT_UINT64 then
    begin
        Result := np.np_array(tensor.Uint64Vals.ToArray).reshape(shape);
    end
    else if tensor.Dtype = TDataType.DT_BOOL then
    begin
        Result := np.np_array(tensor.BoolVals.ToArray).reshape(shape);
    end else
        raise TFException.Create('Not Implemented ("MakeNdarray")');
end;

class function TUtils.as_shape<T>(dims: TArray<T>): TTensorShapeProto;
var
  shape : TTensorShapeProto;
  i     : Integer;
begin
    shape := TTensorShapeProto.Create;
    var v := TValue.From< TArray<T> >(dims) ;

    for i := 0 to Length(dims) - 1 do
    begin
        var dim : TDim ;
        dim := TDim.Create;
        if TypeInfo(T) = TypeInfo(Integer) then
          dim.Size := v.AsType< TArray<Integer> >[i]
        else if TypeInfo(T) = TypeInfo(Int64) then
          dim.Size := v.AsType< TArray<Int64> >[i]
        else
          raise TFException.Create('as_shape Not Implemented');

        shape.Dims.Add(dim);
    end;
    Result := shape;

end;

class function TUtils.as_shape_proto(tshape : TFShape): TTensorShapeProto;
var
  shape : TTensorShapeProto;
  i     : Integer;
begin
    shape := TTensorShapeProto.Create;

    for i := 0 to tshape.ndim - 1 do
    begin
        var dim : TDim ;
        dim := TDim.Create;
        dim.Size := tshape.dims[i];
        //dim.Name = $"dim_{i}";
        shape.Dims.Add(dim);
    end;
    Result := shape;
end;

class function TUtils.shape_tensor(shape : TArray<Integer>): TFTensor;
begin
    Result := Tops.convert_to_tensor( TValue.From< TArray<Integer> >(shape), TF_DataType.TF_INT32, 'shape');
end;

class function TUtils.make_tensor_proto(values: TValue; var dtype: TF_DataType; shape: PTFShape; verify_shape,
                       allow_broadcast: Boolean): TTensorProto;
 var
   bytes  : TArray<Byte>;
begin

    if allow_broadcast and verify_shape then
       raise TFException.Create('allow_broadcast and verify_shape are not both allowed.');

    if values.TypeInfo = TypeInfo(TTensorProto) then
        Exit( values.AsType<TTensorProto> );

    var origin_dtype := GetDataType(values);

    if dtype = TF_DataType.DtInvalid then
        dtype := origin_dtype
    else if origin_dtype <> dtype then
    begin
        var new_system_dtype := Tdtypes.as_system_dtype(dtype);
        if values.IsType< TArray<Int64> > then
        begin
            if dtype = TF_DataType.TF_INT32 then
            begin
                var a := ArrayToArrayTipo<Int64>( values.AsType< TArray<Int64> >, new_system_dtype);
                values := TValue.From< TArray<Integer> >(a);
            end;
        end else
        begin
            values := ChangeType(values, new_system_dtype);
        end;

        dtype := GetDataType(values);
    end;

    var sShape : TFShape;
    if (shape = nil) or (shape.IsNil) then
    begin
        sShape := GetShape(values);
        shape :=  @sShape;
    end;

    var tensor_proto : TTensorProto;
    tensor_proto := TTensorProto.Create;

    tensor_proto.Dtype       := Tdtypes.as_datatype_enum(dtype);
    tensor_proto.TensorShape := TUtils.as_shape_proto(shape);
    
    if values.TypeInfo = TypeInfo(TNDArray) then
    begin
        var nd := values.AsType<TNDArray>;

        // scalar
        if nd.shape.IsScalar then
        begin
            case nd.dtype of
                TF_DataType.TF_BOOL: tensor_proto.BoolVals.AddRange(nd.ToArray<Boolean>);
                TF_DataType.TF_UINT8:
                    begin
                       var a : TArray<Integer>;
                       var b := nd.ToArray<byte>;
                       for var i := 0 to Length(b) - 1 do
                         a := a + [ b[i] ];

                       tensor_proto.IntVals.AddRange(a);
                    end;
                TF_DataType.TF_INT32: tensor_proto.IntVals.AddRange   (nd.ToArray<Integer>);
                TF_DataType.TF_INT64: tensor_proto.Int64Vals.AddRange (nd.ToArray<Int64>);
                TF_DataType.TF_FLOAT: tensor_proto.FloatVals.AddRange (nd.ToArray<Single>);
                TF_DataType.TF_DOUBLE:tensor_proto.DoubleVals.AddRange(nd.ToArray<double>);
                else
                    raise TFException.Create('make_tensor_proto Not Implemented');
            end;
        end else
        begin
            bytes := nd.ToByteArray;
            tensor_proto.TensorContent := bytes;
        end;
    end
    else if (dtype = TF_DataType.TF_STRING) and  (not (values.IsType<TNDArray>)) then
    begin
        if (values.IsType<string>) or (values.IsType<AnsiString>) then
        begin
            var str :=  values.AsType<AnsiString> ;
            bytes := TEncoding.UTF8.GetBytes(string(str));
            tensor_proto.StringVals.Add(bytes);
        end
        else if (values.IsType<TArray<string>>) or (values.IsType<TArray<AnsiString>>) then
        begin
            var a : TArray<TBytes>;
            var b := values.AsType< TArray<string> >;
            for var i := 0 to Length(b) - 1 do
              a := a + [ TEncoding.UTF8.GetBytes( b[i] ) ];
            tensor_proto.StringVals.AddRange( a );
        end
        else if (values.IsType< TArray<Byte> >) then
        begin
            var byte_values := values.AsType< TArray<Byte> >;
            tensor_proto.TensorContent := byte_values;
        end;
    end
    else if values.IsArray then
    begin
        if shape.ndim = 2 then
        begin
            var lenBytes := Tdtypes.get_datatype_size(dtype) * shape.size;
            SetLength(bytes,lenBytes);

            var len0 := values.GetArrayLength;
            var BytesIdx: Integer := 0;
            for var i := 0 to len0-1 do
            begin
                var v1  := values.GetArrayElement(i);
                var len := v1.GetArrayLength;

                var src := v1.GetReferenceToRawArrayElement(0);
                var dst := @bytes[BytesIdx];
                CopyMemory(dst,src, len * Tdtypes.get_datatype_size(dtype) );
                Inc(BytesIdx,len * Tdtypes.get_datatype_size(dtype));
            end;
            tensor_proto.TensorContent := bytes;
        end
        else if shape.ndim = 3 then
        begin
            var lenBytes := Tdtypes.get_datatype_size(dtype) * shape.size;
            SetLength(bytes,lenBytes);

            var len0 := values.GetArrayLength;
            var BytesIdx: Integer := 0;
            for var i := 0 to len0-1 do
            begin
                var v1  := values.GetArrayElement(i);
                var len := v1.GetArrayLength;

                var src := v1.GetReferenceToRawArrayElement(0);
                var dst := @bytes[BytesIdx];
                CopyMemory(dst,src, len * Tdtypes.get_datatype_size(dtype) );
                Inc(BytesIdx,len * Tdtypes.get_datatype_size(dtype));
            end;
            tensor_proto.TensorContent := bytes;
        end else
        begin
            // array
            var len := Tdtypes.get_datatype_size(dtype) * shape.size;
            var src := values.GetReferenceToRawArrayElement(0);
            SetLength(bytes,len);
            if Length(bytes) > 0 then
            begin
               var dst := @bytes[0];
               CopyMemory(dst,src,len);
            end;
            tensor_proto.TensorContent := bytes;
        end;
    end else
    begin
        if values.IsType<TAxis> then
        begin
            var vval := values.AsType<TAxis>;
             tensor_proto.IntVals.AddRange(vval.axis.value);
        end
        else if values.IsType<PAxis> then
        begin
            var pVval := values.AsType<PAxis>;
            var vVal := System.Default(TAxis);
            if Assigned(pVval) then vVal := pVval^;

            tensor_proto.IntVals.AddRange(vval.axis.value);
        end
        else if values.IsType<TFShape> then
        begin
            var vval := values.AsType<TFShape>;
            tensor_proto.Int64Vals.AddRange(vval.dims);
        end
        else if values.IsType<Boolean> then
        begin
            var vval := values.AsType<Boolean>;
            tensor_proto.BoolVals.AddRange([ vval ]);
        end
        else if values.IsType<Int8> and (Values.TypeInfo.Name ='Int8') then
        begin
            var vval := values.AsType<Int8>;
            tensor_proto.IntVals.AddRange([ vval ]);
        end
        else if values.IsType<Integer> and (Values.TypeInfo.Name ='Integer')then
        begin
            var vval := values.AsType<Integer>;
            tensor_proto.IntVals.AddRange([ vval ]);
        end
        else if values.IsType<Int64> and (Values.TypeInfo.Name ='Int64') then
        begin
            var vval := values.AsType<Int64>;
            tensor_proto.Int64Vals.AddRange([ vval ]);
        end
        else if (values.IsType<Single>) and (Values.TypeInfo.Name ='Single') then
        begin
            var vval := values.AsType<Single>;
            tensor_proto.FloatVals.AddRange([ vval ]);
        end
        else if (values.IsType<Single>) and (Values.TypeInfo.Name ='Double') then
        begin
            var vval := values.AsType<Double>;
            tensor_proto.DoubleVals.AddRange([ vval ]);
        end else
        begin
           if Values.TypeInfo.Kind = tkInteger      then
           begin
               var TipoData := values.typeinfo.TypeData;
               if  Tipodata.OrdType = otSByte then
               begin
                   var vval := values.AsType<Int8>;
                   tensor_proto.IntVals.AddRange([ vval ]);
               end else
               if  Tipodata.OrdType = otUByte then
               begin
                   var vval := values.AsType<byte>;
                   tensor_proto.IntVals.AddRange([ vval ]);
               end
               else if  Tipodata.OrdType = otSWord then
               begin
                   var vval := values.AsType<Int16>;
                   tensor_proto.IntVals.AddRange([ vval ]);
               end else
               if  Tipodata.OrdType = otUWord then
               begin
                   var vval := values.AsType<Word>;
                   tensor_proto.IntVals.AddRange([ vval ]);
               end
               else if  Tipodata.OrdType = otSLong then
               begin
                   var vval := values.AsType<Int64>;
                   tensor_proto.Int64Vals.AddRange([ vval ]);
               end else
               if  Tipodata.OrdType = otULong then
               begin
                   var vval := values.AsType<UInt64>;
                   tensor_proto.Int64Vals.AddRange([ vval ]);
               end
               else if  Tipodata.OrdType = otULong then
               begin
                   var vval := values.AsType<Integer>;
                   tensor_proto.IntVals.AddRange([ vval ]);
               end;
           end
           else if Values.TypeInfo.Kind = tkFloat      then
           begin
               var TipoData := values.typeinfo.TypeData;
               if  Tipodata.FloatType = ftSingle then
               begin
                   var vval := values.AsType<Single>;
                   tensor_proto.FloatVals.AddRange([ vval ]);
               end else
               if  Tipodata.FloatType = ftDouble then
               begin
                   var vval := values.AsType<Double>;
                   tensor_proto.DoubleVals.AddRange([ vval ]);
               end
           end else
           begin
               //var TestVAlue := values.typeinfo.TypeData;
               raise Exception.Create('make_tensor_proto Type not supported :'+ string(values.TypeInfo.Name));
           end;
        end;
    end;
    Result := tensor_proto;

end;

class function TUtils.ParseSlices(slices: TArray<Slice>): ParsedSliceArgs;
begin
    var abegin := TList<Integer>.Create;
    var aend   := TList<Integer>.Create;
    var strides:= TList<Integer>.Create;
    try
      var index            : Integer := 0;
      var new_axis_mask    : Integer := 0;
      var shrink_axis_mask : Integer := 0;
      var begin_mask       : Integer := 0;
      var end_mask         : Integer := 0;
      var ellipsis_mask    : Integer := 0;
      for var s in slices do
      begin
          if s.IsNewAxis then
          begin
              abegin.Add(0);
              aend.Add(0);
              strides.Add(1);
              new_axis_mask := new_axis_mask or (1 shl index);
          end
          else if s.IsEllipsis then
          begin
              abegin.Add(0);
              aend.Add(0);
              strides.Add(1);
              ellipsis_mask := ellipsis_mask or (1 shl index);
          end else
          begin
              if s.Start.HasValue then
              begin
                  abegin.Add(s.Start.Value);
              end else
              begin
                  abegin.Add(0);
                  begin_mask := begin_mask or (1 shl index);
              end;
              if s.Stop.HasValue then
              begin
                  aend.Add(s.Stop.Value);
              end else
              begin
                  aend.Add(0);
                  end_mask := end_mask or (1 shl index);
              end;
              strides.Add(s.Step);
              if s.IsIndex then
                  shrink_axis_mask := shrink_axis_mask or (1 shl index);
          end;
          Inc(index);
      end;
      Result := System.default(ParsedSliceArgs);
      Result.aBegin         := abegin.ToArray;
      Result.aEnd           := aend.ToArray;
      Result.aStrides       := strides.ToArray;
      Result.iBeginMask     := begin_mask;
      Result.iEndMask       := end_mask;
      Result.iEllipsisMask  := ellipsis_mask;
      Result.iShrinkAxisMask:= shrink_axis_mask;
      Result.iNewAxisMask   := new_axis_mask ;
    finally
      abegin.free;
      aend.free;
      strides.free;
    end;
end;

class function TUtils.ParseSlices(start: TFTensor; stop: TFTensor ; step: TFTensor): ParsedSliceArgs;
begin
    var abegin := TList<TFTensor>.Create;
    var aend   := TList<TFTensor>.Create;
    var strides:= TList<TFTensor>.Create;
    try
      var index            : Integer := 0;
      var new_axis_mask    : Integer := 0;
      var shrink_axis_mask : Integer := 0;
      var begin_mask       : Integer := 0;
      var end_mask         : Integer := 0;
      var ellipsis_mask    : Integer := 0;

      abegin.Add(start);

      if stop = nil then
          aend.Add(TTensor(start) + 1)
      else
          aend.Add(stop);
      shrink_axis_mask := shrink_axis_mask or (1 shl index);
      if step = nil then
          strides.Add( tf.constant(1, start.dtype) )
      else
          strides.Add(step);

      Result := System.default(ParsedSliceArgs);
      Result.tPackedBegin   := array_ops.stack(abegin.ToArray);
      Result.tPackedEnd     := array_ops.stack(aend.ToArray);
      Result.tPackedStrides := array_ops.stack(strides.ToArray);
      Result.iBeginMask     := begin_mask;
      Result.iEndMask       := end_mask;
      Result.iEllipsisMask  := ellipsis_mask;
      Result.iShrinkAxisMask:= shrink_axis_mask;
      Result.iNewAxisMask   := new_axis_mask ;
    finally
      abegin.free;
      aend.free;
      strides.free;
    end;
end;

class function TUtils.SequenceEqual<T>(const v1, v2: TArray<T>): boolean;
var
  comparer: IEqualityComparer<T>;
  i: Integer;
begin
  comparer := TEqualityComparer<T>.Default;
  for i := Low(v1) to High(v1) do
    if not comparer.Equals(v1[i], v2[i]) then
      Exit(false);
  Result := true;

end;

class function TUtils.isinstance(v: TValue; t : PTypeInfo):Boolean;
begin
    Result := v.TypeInfo = t
end;

class function TUtils.IsInstance<T>(tipo1 : T; Tipo2: PTypeInfo): boolean;
begin
    Result := PTypeInfo(TypeInfo(T)) = Tipo2;
end;

class function TUtils.IsInstance<T,T1,T2>(tipo1 : T; Tipo2: Tuple<T1,T2>): boolean;
begin
    Result := False;
    if PTypeInfo(TypeInfo(T)) = PTypeInfo(TypeInfo(T1)) then
      Exit(True);
   if PTypeInfo(TypeInfo(T)) = PTypeInfo(TypeInfo(T2)) then
      Exit(True);
end;

class function TUtils.IsInstance<T,T1,T2,T3>(tipo1 : T; Tipo2: Tuple<T1,T2,T3>): boolean;
begin
    Result := False;
    if PTypeInfo(TypeInfo(T)) = PTypeInfo(TypeInfo(T1)) then
      Exit(True);
   if PTypeInfo(TypeInfo(T)) = PTypeInfo(TypeInfo(T2)) then
      Exit(True);
   if PTypeInfo(TypeInfo(T)) = PTypeInfo(TypeInfo(T3)) then
      Exit(True);
end;

class function TUtils.IsSubSet<T>(subSet: TArray<T>; source: TList<T>): Boolean;
begin
    var lIsSubSet := true;
    for var element in subset do
    begin
        if not source.Contains(element) then
        begin
            lIsSubSet := false;
            continue;
        end;
    end;

    Result := lIsSubSet;
end;

class procedure TUtils.DownloadAsync(url, dirSaveTo, fileName: string; showProgressInConsole: Boolean);
var
  IdHTTP1 : TIdHTTP;
  IdSSL   : TIdSSLIOHandlerSocketOpenSSL;
  Stream  : TMemoryStream;
begin
    if not TPath.IsPathRooted(dirSaveTo) then
        dirSaveTo := TPath.Combine(ExtractFileDir(ParamStr(0)), dirSaveTo);

    var fileSaveTo := TPath.Combine(dirSaveTo, fileName);

    if (showProgressInConsole) and (IsConsole) then
      WriteLn('Downloading '+ fileName);

    if FileExists(fileSaveTo) then
    begin
        if (showProgressInConsole) and (IsConsole) then
          WriteLn('The file '+ fileName +' already exists');
        Exit;
    end;

    TDirectory.CreateDirectory(dirSaveTo);

    IdHTTP1 := TIdHTTP.Create(nil);
    IdSSL := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP1);
    IdSSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    IdHTTP1.IOHandler := IdSSL;
    Stream := TMemoryStream.Create;
    try
      IdHTTP1.Get(url, Stream);
      Stream.SaveToFile(fileSaveTo);
    finally
      Stream.Free;
      IdHTTP1.Free;
    end;
end;

class procedure TUtils.UnzipAsync(zipFile, saveTo: string; showProgressInConsole: Boolean);
var
  DecompressionStream: TDecompressionStream;
  FileStreamIn,
  FileStreamOut      : TFileStream;
begin
    if not TPath.IsPathRooted(saveTo) then
        saveTo := TPath.Combine(ExtractFileDir(ParamStr(0)), saveTo);

    TDirectory.CreateDirectory(SaveTo);

    if not TPath.IsPathRooted(zipFile) then
        zipFile := TPath.Combine(ExtractFileDir(ParamStr(0)), zipFile);

    var destFileName := TPath.GetFileNameWithoutExtension(zipFile);
    var destFilePath := TPath.Combine(saveTo, destFileName);

    if (showProgressInConsole) and (IsConsole) then
        WriteLn('Unzippinng '+ TPath.GetFileName(zipFile));

    if FileExists(destFilePath) then
    begin
       if (showProgressInConsole) and (IsConsole) then
            WriteLn('The file '+ destFileName + ' already exists');
    end;

    FileStreamIn  := TFileStream.Create(zipFile, fmOpenRead);
    FileStreamOut := TFileStream.Create(destFilePath, fmCreate);
    try
       DecompressionStream := TDecompressionStream.Create(FileStreamIn, 15 + 16);
       try
         FileStreamOut.CopyFrom(DecompressionStream, 0);
       finally
         DecompressionStream.Free;
       end;
    finally
      FileStreamIn.Free;
      FileStreamOut.Free;
    end;
end;

class function TUtils.DecompressTGZ(tgzFile: string; baseDir: string; isTar: Boolean): Boolean;
begin
    Result := False;
    var UnZipper := TAbUnZipper.Create(nil);
    try
      try
        UnZipper.ArchiveType   := atGzip;
        UnZipper.ForceType     := True;
        UnZipper.BaseDirectory := baseDir;
        UnZipper.ExtractOptions:= [eoCreateDirs];
        UnZipper.FileName      := tgzFile;
        if isTar then
        begin
           UnZipper.ExtractFiles('*')
        end
        else begin
            UnZipper.ExtractAt(0, TPath.Combine(baseDir, ChangeFileExt(tgzFile,'')) );
            Exit;
        end;

        UnZipper.ArchiveType := atTar;
        UnZipper.FileName    := TPath.Combine(baseDir, UnZipper.Items[0].FileName);

        for var i := 0 to UnZipper.Count - 1 do
        begin
            if UnZipper.Items[i].IsDirectory then
            begin
              TDirectory.CreateDirectory( TPath.Combine( baseDir, UnZipper.Items[i].FileName) );
              UnZipper.BaseDirectory := TPath.Combine( baseDir, UnZipper.Items[i].FileName);
            end;
            UnZipper.ExtractAt(i,TPath.Combine( baseDir, UnZipper.Items[i].FileName));
        end;
      except
        Result := False
      end;
    finally
      var f := UnZipper.FileName;
      UnZipper.Free;
      DeleteFile(PChar(f)) ;
    end;
    Result := True;
end;

{ TValueHelper }

class operator TValueHelp.Implicit(Const Value: Uint8):TValue;
begin
  Result := TValue.From<Uint8>(Value);
end ;
class operator TValueHelp.Implicit(Const Value: Int8):TValue;
begin
  Result := TValue.From<Int8>(Value);
end ;

class operator TValueHelp.Implicit(const Value: TValue): TFTensor;
begin
    Result := nil;

    if Value.IsType<TFTensor> then
      Result := Value.AsType<TFTensor>
end;

class operator TValueHelp.Implicit(const Value: TArray<TFTensor>): TValue;
begin
    Result := TValue.From< TArray<TFTensor> >(Value);
end;

class operator TValueHelp.Implicit(const Value: TFTensor): TValue;
begin
    Result := TValue.From<TFTensor>(Value);
end;

class operator TValueHelp.Implicit(const Value: TF_DataType): TValue;
begin
    Result := TValue.From<Integer>(Ord(Value));
end;

class operator TValueHelp.Implicit(const Value: TValue): TNDArray;
begin
    Result := nil;

    if Value.IsType<TNDArray> then
      Result := Value.AsType<TNDArray>
end;

class operator TValueHelp.Implicit(const Value: TNDArray): TValue;
begin
   Result := TValue.From<TNDArray>(Value);
end;

class operator TValueHelp.Implicit(const Value: TValue): NDArray;
begin
    Result := Value.AsType<NDArray>
end;

class operator TValueHelp.Implicit(const Value: NDArray): TValue;
begin
   Result := TValue.From<TNDArray>(Value.HandleNDArray);
end;

class operator TValueHelp.Implicit(const Value: TValue): TTensor;
begin
    Result := Value.AsType<TTensor>
end;

class operator TValueHelp.Implicit(const Value: TTensor): TValue;
begin
     Result := TValue.From<TFTensor>(Value.HTensor);
end;

class operator TValueHelp.Implicit(const Value: TArray<TArray<Integer>>): TValue;
begin
   Result := TValue.From< TArray<TArray<Integer>> >(Value);
end;

class operator TValueHelp.Implicit(const Value: TArray<Integer>): TValue;
begin
    Result := TValue.From< TArray<Integer> >(Value);
end;

class operator TValueHelp.Implicit(const Value: TArray<Single>): TValue;
begin
    Result := TValue.From< TArray<Single> >(Value);
end;

class operator TValueHelp.Implicit(const Value: TArray<TArray<TArray<Integer>>>): TValue;
begin
   Result := TValue.From< TArray<TArray<TArray<Integer>>> >(Value);
end;

class operator TValueHelp.Implicit(const Value: TArray<TArray<Double>>): TValue;
begin
    Result := TValue.From< TArray<TArray<Double>> >(Value);
end;

class operator TValueHelp.Implicit(const Value: TArray<Int64>): TValue;
begin
   Result := TValue.From< TArray<Int64> >(Value);
end;

class operator TValueHelp.Implicit(const Value: TArray<String>): TValue;
begin
     Result := TValue.From< TArray<String> >(Value);
end;

class operator TValueHelp.Implicit(const Value: TArray<Byte>): TValue;
begin
    Result := TValue.From< TArray<Byte> >(Value);
end;

class operator TValueHelp.Implicit(const Value: TArray<TArray<Single>>): TValue;
begin
    Result := TValue.From< TArray<TArray<Single>> >(Value);
end;

{ nest }

class function nest.is_Sequence<T>(arg: T): Boolean;
begin
    var v := TValue.From<T>(arg);
    Result := v.IsArray;
    if (not Result) and (v.IsType<TFTensors>) then Result := True;

    if (not Result) and (v.IsType<TList<T>>) then Result := True;
end;

class function nest.map_structure<T>(func: TFunc<T, TFTensor>; structure: TValue): TFTensor;
 var
  _flat_structure : TList<T> ;
  flat_structure  : Enumerable<T>;
begin
    _flat_structure := flatten<T>(structure);
    flat_structure  := Enumerable<T>.Create(_flat_structure.ToArray);

    var flat_structure_t := TList<TFTensor>.Create( flat_structure.Select<TFTensor>(func).ToArray );

    Result := pack_sequence_as(structure.AsType<T>, TList<TObject>(flat_structure_t)) as TFTensor;
end;

class function nest._sorted<Tk,Tv>(dict_:TDictionary<Tk, Tv>): TArray<Tk>;
begin
    var list : TList<Tk> := TList<Tk>.Create(dict_.Keys);
    try
      list.Sort;
      Result := list.ToArray;
    finally
      list.Free;
    end;
end;

class function nest.Flatten<T>(structure: TValue):  TList<T>;
var
  list: TList<T>;
begin
    list := TList<T>.Create;
    _flatten_recursive<T>(structure, list);
    Result := list;
end;

class procedure nest._flatten_recursive<T>(obj: TValue; list: TList<T>);
var
  i: Integer;
begin

    if Obj.isArray then
    begin
        for i := 0 to Obj.GetArrayLength - 1 do
          _flatten_recursive<T>(Obj.GetArrayElement(i), list);
    end
    else if Obj.IsType<string> then
    begin
       list.Add(Obj.AsType<T>);
    end
    else if Obj.IsType<TList<T>> then
    begin
        list.AddRange(Obj.AsType<TList<T>>);
    end
    else if Obj.IsType<TNDArray> then
    begin
        list.Add(Obj.AsType<T>);
    end
    else if Obj.TypeInfo = TypeInfo(TValue)  then
    begin
        var v := Obj.AsType<TValue>;
        _flatten_recursive(v, list);
    end else
    begin
        list.Add(Obj.AsType<T>);
    end;
end;

class function nest.is_Mapping<T>(arg: T): Boolean;
begin
    Result := false;
    var v := TValue.From<T>(arg) ;

    if string(v.TypeInfo.Name).ToLower.Contains('TDictionary') then Result := True;
end;

class function nest.SequenceLike<Tk,Tv>(instance: TDictionary<Tk,Tv>; args: TArray<Tk>): TObject;
var
  keyList: TList<Tk>;
  keyArray: TArray<Tk>;
  i: Integer;
begin
    keyList := TList<Tk>.Create;
    for var key in instance.Keys do
      keyList.Add(key);
    keyList.Sort;

    keyArray := keyList.ToArray;
    result := TDictionary<Tk, Tv>.Create;
    for i := 0 to High(keyArray) do
      TDictionary<Tk, Tv>(result).Add( keyArray[i], instance[ keyArray[i] ]);
    Result := result;
end;

class function nest.SequenceLike<T>(instance: T; args: TArray<TObject>): TObject;
begin
    var v := TValue.From<T>(instance) ;
    if TypeInfo(T) = TypeInfo(TList<T>) then
    begin
      result := TList<TObject>.Create;
      TList<TObject>(result).AddRange(args);
    end
    else if v.IsArray then
    begin
      var res := TArray<TObject>.Create();
      TArray.Copy<TObject>(args, res, Length(args));
      Result := TObject(res);
    end
    else
    begin
      raise Exception.Create('Type of sequence not supported (yet)');
    end;
end;

class function nest._yield_value<T>(Iter : T ): TArray<T>;
begin
    var v := TValue.From<T>(Iter) ;
    if TypeInfo(T) = TypeInfo(TList<T>) then
    begin
      var res := TList<T>.Create;
      res.AddRange( v.AsType<TList<T> > );
    end
    else if v.IsArray then
    begin
      var res := TArray<T>.Create();
      TArray.Copy<T>( v.AsType<TArray<T> >, res, v.GetArrayLength);
      Result := res;
    end
    else
    begin
      raise Exception.Create('Type of sequence not supported (yet)');
    end;
end;

class function nest._packed_nest_with_indices<T>(structure : T; flat: TList<TObject>; index: Integer): Tuple<Integer, TList<TObject>> ;
begin
    var pPacked := TList<TObject>.Create;
    for var s in _yield_value(structure) do
    begin
        if is_sequence(s) then
        begin
            var tPack := _packed_nest_with_indices(s, flat, index);
            var new_index := tPack.Value1;
            var child     := tPack.Value2;

            pPacked.Add( SequenceLike(s, child.ToArray) );
            index := new_index;
        end else
        begin
            pPacked.Add(flat[index]);
            index := index + 1;
        end;
    end;
    Result := Tuple.Create(index, pPacked);
end;

class function nest.pack_sequence_as<T>(structure: T; flat_sequence: TEnumerable<TObject>; expand_composites: Boolean): TObject;
var
  flat     : TList<TObject>;
  pPacked: TList<TObject>;
begin

    if flat_sequence is TList<TObject> then  flat := flat_sequence as TList<TObject>
    else                                     flat := TList<TObject>.Create;

    if not is_Sequence<T>(structure) then
    begin
       if flat.Count > 1 then
         raise Exception.Create('Structure is a scalar but len(flat_sequence) = '+ flat.Count.ToString + ' > 1');

       Exit(flat.First)
    end;

    pPacked := nil;
    try
      var tPack := _packed_nest_with_indices(structure, flat, 0);
      var final_index := tPack.Value1;
      pPacked     := tPack.Value2;
      if final_index < flat.Count then
         raise Exception.Create('Final index: '+ final_index.ToString +' was smaller than  len(flat_sequence): '+flat.Count.ToString);
      Result := SequenceLike(structure, pPacked.ToArray);
    Except
      Result := SequenceLike(structure, pPacked.toArray);
    end;
end;

{ TTuple<T1, T2> }

constructor TTuple<T1, T2>.Create(const AFirst: T1; const ASecond: T2);
begin
  inherited Create;
  FFirst := AFirst;
  FSecond := ASecond;
end;

end.
