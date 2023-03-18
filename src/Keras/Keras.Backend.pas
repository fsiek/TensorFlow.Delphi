unit Keras.Backend;
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

{$WARN IMPLICIT_STRING_CAST OFF}
{$WARN IMPLICIT_STRING_CAST_LOSS OFF}

interface
    uses System.SysUtils,
         System.Math,
         System.Generics.Collections,
         System.TypInfo,
         rtti,

         Spring,

         TensorFlow.Variable,
         TensorFlow.Training,
         Tensorflow.Utils,
         TF4D.Core.CApi,
         TensorFlow.Core,
         TensorFlow.DApi;

type

 ImageDimOrder   = (tf, th);
 ImageDataFormat = ( channels_last, channels_first );

 GraphLearningPhase = ( train_mode = 1, test_mode = 0 );

 BackendBase = class abstract
   var
     _FLOATX            : TF_DataType;
     _EPSILON           : Single;
     _IMAGE_DATA_FORMAT : ImageDataFormat;
   public
      constructor Create;
      function  epsilon: Single;
      procedure set_epsilon(e: Single);
      function  floatx : TF_DataType;
      procedure set_floatx(__floatx: TF_DataType);
      //public NDArray cast_to_floatx(NDArray x) => np.array(x, dtype: _FLOATX.as_numpy_datatype());
      function  image_data_format: ImageDataFormat;
      procedure set_image_data_format(data_format: ImageDataFormat);
      function  normalize_data_format(value : PValue= nil): ImageDataFormat;
      procedure set_image_dim_ordering(dim_ordering: ImageDimOrder);
      function  image_dim_ordering: ImageDimOrder;
 end;

 _DummyEagerGraph = class

 end;

 BackendImpl = class(BackendBase)
   private

   public
      (* ----------------------------------------  KERAS BACKEND NATIVE OBJECTS  ---------------------------------------- *)
      py_sum : TFunc<TArray< TValue >, Double>;
      py_all : TFunc<TArray< TValue >, Boolean>;
      //Func<Array, bool> py_any = any;
      //Func<double, double, double, IEnumerable<double>> py_slice = slice;

      _SESSION               : TFSession;

      _GRAPH                 : TFGraph;
      _CURRENT_SCRATCH_GRAPH : TFuncGraph;
      _GRAPH_LEARNING_PHASES : TDictionary<TFGraph, GraphLearningPhase>;
      //Dictionary<Graph, Dictionary<string, int>> PER_GRAPH_LAYER_NAME_UIDS;
      _MANUAL_VAR_INIT       : Boolean;
      _LOCAL_DEVICES         : TList<string>;
      (* --------------------------------------  KERAS BACKEND NATIVE OBJECTS END  -------------------------------------- *)
      /// <summary>
      /// A global dictionary mapping graph objects to an index of counters used
      /// for various layer names in each graph.
      /// Allows to give unique autogenerated names to layers, in a graph-specific way.
      /// </summary>
      PER_GRAPH_LAYER_NAME_UIDS : TDictionary<TFGraph, TDictionary<string, Integer>> ;
      _GRAPH_VARIABLES          : TDictionary<string, IVariableV1>;
      _GRAPH_TF_OPTIMIZERS      : TDictionary<string, Optimizer>;
      _DUMMY_EAGER_GRAPH        : _DummyEagerGraph;

      constructor Create;
      destructor Destroy; override;
      procedure track_variable(v: IVariableV1);
      function  placeholder(shape : PTFShape= nil; ndim : Integer = -1; dtype : TF_DataType = DtInvalid; sparse: Boolean = false; name: string = ''; ragged : Boolean= false): TFTensor;
      function  get_graph: TFGraph;
      function  _scratch_graph: TFuncGraph;
      function  get_uid(prefix: string): Integer;
      procedure reset_uids;
      procedure clear_session;
      procedure manual_variable_initialization(value: Boolean);
      function  mean(x: TFTensor; axis: Integer = -1; keepdims : Boolean= false): TFTensor;
      function  learning_phase: GraphLearningPhase;
      procedure set_learning_phase(value: Boolean);
      procedure batch_set_value(tuples: TList< Tuple<IVariableV1,TNDArray> >) ;
      /// <summary>
      /// Pads the 2nd and 3rd dimensions of a 4D tensor.
      /// </summary>
      /// <param name="x"></param>
      /// <param name="padding"></param>
      /// <param name="data_format"></param>
      /// <returns></returns>
      function spatial_2d_padding(x: TFTensor; padding : TNDArray= nil; data_format: string = ''): TFTensor;
      /// <summary>
      /// Method to evaluate a tensor in eager or in a tf.function.
      /// </summary>
      /// <param name="outputs"></param>
      /// <returns></returns>
      function eval_in_eager_or_function(outputs: TFTensors): TNDArray;
      /// <summary>
      /// Categorical crossentropy between an output tensor and a target tensor.
      /// </summary>
      /// <param name="target"></param>
      /// <param name="output"></param>
      /// <param name="from_logits"></param>
      /// <param name="axis"></param>
      /// <returns></returns>
      function categorical_crossentropy(target: TFTensor; output: TFTensor; from_logits: Boolean = false; axis: Integer = -1) : TFTensor;
      function binary_crossentropy(target: TFTensor; output: TFTensor; from_logits: Boolean = false): TFTensor;
      /// <summary>
      /// Resizes the images contained in a 4D tensor.
      /// </summary>
      /// <param name="x"></param>
      /// <param name="height_factor"></param>
      /// <param name="width_factor"></param>
      /// <param name="data_format"></param>
      /// <param name="interpolation"></param>
      /// <returns></returns>
      function resize_images(x: TFTensor; height_factor: Integer; width_factor: Integer; data_format: string; interpolation : string= 'nearest'): TFTensor;
      /// <summary>
      /// Concatenates a list of tensors alongside the specified axis.
      /// </summary>
      /// <param name="tensors">list of tensors to concatenate.</param>
      /// <param name="axis">concatenation axis.</param>
      /// <returns></returns>
      function concatenate(tensors: TFTensors; axis: Integer = -1): TFTensor;
      function conv2d_transpose(x: TFTensor; kernel: IVariableV1; output_shape: TFTensor; strides: PTFShape = nil; padding: string = 'valid'; data_format : string= ''; dilation_rate: PTFShape = nil): TFTensor;
      function sparse_categorical_crossentropy(target: TFTensor; output: TFTensor; from_logits: Boolean = false; axis: Integer = -1; ignore_class: PInteger = nil): TFTensor;
 end;

implementation
        uses Tensorflow,
             TensorFlow.Tensor,
             TensorFlow.clip_ops,
             TensorFlow.Ops,
             TensorFlow.Slice,
             Tensorflow.array_ops,
             Tensorflow.math_ops,
             TensorFlow.image_ops_impl,
             TensorFlow.nn_impl,

             Numpy,
             NumPy.NDArray,
             Numpy.Axis ;

{ BackendBase }

constructor BackendBase.Create;
begin
    _FLOATX            := TDtypes.cfloat32;
    _EPSILON           := 1e-7;
    _IMAGE_DATA_FORMAT := ImageDataFormat.channels_last;
end;

function  BackendBase.epsilon: Single;
begin
    Result := _EPSILON
end;

procedure BackendBase.set_epsilon(e: Single);
begin
    _EPSILON := e
end;

function  BackendBase.floatx : TF_DataType;
begin
    Result := _FLOATX;
end;

procedure BackendBase.set_floatx(__floatx: TF_DataType);
begin
    _FLOATX := __floatx
end;

//public NDArray cast_to_floatx(NDArray x) => np.array(x, dtype: _FLOATX.as_numpy_datatype());
function  BackendBase.image_data_format: ImageDataFormat;
begin
    Result := _IMAGE_DATA_FORMAT
end;

procedure BackendBase.set_image_data_format(data_format: ImageDataFormat);
begin
    _IMAGE_DATA_FORMAT := data_format
end;

function  BackendBase.normalize_data_format(value : PValue= nil): ImageDataFormat;
begin
    // for delphi warming
    Result := ImageDataFormat.channels_last;

    if value = nil then
    begin
        var v : TValue := TValue.From<ImageDataFormat>(_IMAGE_DATA_FORMAT);
        value := @v;
    end;
    if value^.IsType<ImageDataFormat> then
    begin
        Result :=  value^.AsType<ImageDataFormat>;
        Exit;
    end
    else if value^.IsType<string>  then
    begin
        var sEnum      : string := value^.AsType<string>;
        if (sEnum.Contains('channels_last')) or (sEnum.Contains('channels_first')) then
        begin
            if      sEnum.Contains('channels_last')  then  Result := ImageDataFormat.channels_last
            else if sEnum.Contains('channels_first')  then Result := ImageDataFormat.channels_first;
            Exit;
        end;
    end;
    raise Exception.Create('The `data_format` argument must be one of "channels_first", "channels_last". Received: ' + value^.TypeInfo^.Name);
end;

procedure BackendBase.set_image_dim_ordering(dim_ordering: ImageDimOrder);
begin
    if      dim_ordering = ImageDimOrder.th then _IMAGE_DATA_FORMAT := ImageDataFormat.channels_first
    else if dim_ordering = ImageDimOrder.tf then _IMAGE_DATA_FORMAT := ImageDataFormat.channels_last
    else                                         raise Exception.Create('Unknown dim_ordering:');
end;

function  BackendBase.image_dim_ordering: ImageDimOrder;
begin
    if _IMAGE_DATA_FORMAT = ImageDataFormat.channels_first then Result := ImageDimOrder.th
    else                                                        Result := ImageDimOrder.tf;
end;

{ BackendImpl }

constructor BackendImpl.Create;
begin
    inherited Create;

    py_sum := sum;
    py_all := all;

    _SESSION         := Tops.get_default_session;
    _MANUAL_VAR_INIT := false;
    _LOCAL_DEVICES   := nil;

    PER_GRAPH_LAYER_NAME_UIDS := TDictionary<TFGraph, TDictionary<string, Integer>>.Create;
    _GRAPH_VARIABLES          := TDictionary<string, IVariableV1>.Create;
    _GRAPH_TF_OPTIMIZERS      := TDictionary<string, Optimizer>.Create;

    _DUMMY_EAGER_GRAPH := _DummyEagerGraph.Create;
end;

destructor BackendImpl.Destroy;
begin
  _SESSION.Free;
   Tops.clear_default_graph;

  PER_GRAPH_LAYER_NAME_UIDS.Clear;
  PER_GRAPH_LAYER_NAME_UIDS.Free;

  _GRAPH_VARIABLES.Clear;
  _GRAPH_VARIABLES.Free;

  _GRAPH_TF_OPTIMIZERS.Clear;
  _GRAPH_TF_OPTIMIZERS.Free;

  _DUMMY_EAGER_GRAPH.Free;

  if Assigned(_GRAPH) then
    _GRAPH.Free;

  inherited Destroy;
end;

procedure BackendImpl.track_variable(v: IVariableV1);
begin
    var graph := v.Graph;
    _GRAPH_VARIABLES.AddOrSetValue(graph.graph_key, v);
end;

function BackendImpl.placeholder(shape: PTFShape; ndim: Integer; dtype: TF_DataType; sparse: Boolean; name: string; ragged: Boolean): TFTensor;
begin
    if sparse then
    begin
        raise Exception.Create('placeholder sparse is true');
    end else
    begin
        Result := array_ops.placeholder(dtype, shape, name);
    end;
end;

function BackendImpl.get_graph: TFGraph;
begin
    if Tensorflow.tf.Context.executing_eagerly then
    begin
        if _GRAPH = nil then
            _GRAPH := TFuncGraph.Create('keras_graph');

        Result := _GRAPH;
        Exit;
    end;
    Result := Tops.get_default_graph;
end;

function BackendImpl._scratch_graph: TFuncGraph;
begin
    if _CURRENT_SCRATCH_GRAPH = nil then
        _CURRENT_SCRATCH_GRAPH := TFuncGraph.Create('keras_scratch_graph');

    Result := _CURRENT_SCRATCH_GRAPH;
end;

function BackendImpl.get_uid(prefix: string): Integer;
begin
    var graph := Tensorflow.tf.get_default_graph;

    if not PER_GRAPH_LAYER_NAME_UIDS.ContainsKey(graph) then
        PER_GRAPH_LAYER_NAME_UIDS.Add(graph,  TDictionary<string, Integer>.Create);

    if not PER_GRAPH_LAYER_NAME_UIDS[graph].ContainsKey(prefix) then
        PER_GRAPH_LAYER_NAME_UIDS[graph].AddOrSetValue(prefix, 0);

    PER_GRAPH_LAYER_NAME_UIDS[graph][prefix] := PER_GRAPH_LAYER_NAME_UIDS[graph][prefix] + 1;

    Result := PER_GRAPH_LAYER_NAME_UIDS[graph][prefix];
end;

procedure BackendImpl.reset_uids;
begin
    PER_GRAPH_LAYER_NAME_UIDS := TDictionary<TFGraph, TDictionary<string, Integer>>.Create
end;

procedure BackendImpl.clear_session;
begin
    Tensorflow.tf.Context.reset_context;
    reset_uids;
    // var phase = tf.placeholder_with_default(false, new int[] { }, name: "keras_learning_phase");
    if _GRAPH_LEARNING_PHASES <> nil then
        _GRAPH_LEARNING_PHASES.Clear;

    PER_GRAPH_LAYER_NAME_UIDS.Clear;
    _CURRENT_SCRATCH_GRAPH := nil;
    _GRAPH := nil;

    Tops.set_default_session( Tensorflow.tf.Session(Tops.get_default_graph) );
    Tensorflow.tf.enable_eager_execution;
    Tensorflow.tf.Runner.ClearEagerOperationMap;

    //GC.Collect();
    //GC.WaitForPendingFinalizers();
end;

procedure BackendImpl.manual_variable_initialization(value: Boolean);
begin
    _MANUAL_VAR_INIT := value;
end;

function BackendImpl.mean(x: TFTensor; axis: Integer; keepdims: Boolean): TFTensor;
begin
    if tdtypes.as_base_dtype(x.dtype) = TF_DataType.TF_BOOL then
        x := math_ops.cast(x, TF_DataType.TF_FLOAT);
    var _axis : TAxis := axis;
    Result := math_ops.reduce_mean(x, @_axis, false);
end;

function BackendImpl.learning_phase: GraphLearningPhase;
begin
    var graph := Tensorflow.tf.get_default_graph;
    if _GRAPH_LEARNING_PHASES.ContainsKey(graph) then
    begin
        Tensorflow.tf.placeholder_with_default(false, [], 'keras_learning_phase');
        _GRAPH_LEARNING_PHASES[graph] := GraphLearningPhase(0);
    end;
    Result := _GRAPH_LEARNING_PHASES[graph];
end;

procedure BackendImpl.set_learning_phase(value: Boolean);
begin
     var v : Integer;
     if   value then v := 1
     else            v := 0;

    _GRAPH_LEARNING_PHASES.AddOrSetValue(Tensorflow.tf.get_default_graph, GraphLearningPhase(v) );
end;

procedure BackendImpl.batch_set_value(tuples: TList<Tuple<IVariableV1, TNDArray>>);
begin
    if Tops.executing_eagerly_outside_functions then
    begin
        for var t in tuples do
        begin
             var x    := t.Value1;
             var value:= t.Value2;

             if      x is RefVariable          then (x as RefVariable)         .assign(value, False)
             else if x is BaseResourceVariable then (x as BaseResourceVariable).assign(value, False)
        end;
    end else
    begin
        raise Exception.Create('Not Implemented');
    end;
end;

function BackendImpl.sparse_categorical_crossentropy(target, output: TFTensor; from_logits: Boolean; axis: Integer; ignore_class: PInteger): TFTensor;
begin
    target := Tensorflow.tf.cast(target, Tensorflow.tf.int64_t);
    if not from_logits then
    begin
        var epsilon_ : TTensor := constant_op.constant(epsilon, TDTypes.as_base_dtype(output.dtype),'Const');
        output       := Tensorflow.tf.clip_by_value(output, epsilon_, Integer(1) - epsilon_);
        output       := Tensorflow.tf.math.log(output);
    end;
    var output_rank := output.shape.ndim;
    if output_rank > -1 then
    begin
        axis := Abs(axis) mod output_rank;
        if axis <> (output_rank - 1) then
        begin
            (*var permutation = list(
                itertools.chain(
                    range(axis), range(axis + 1, output_rank), [axis]
                )
            );
            output = tf.transpose(output, perm: permutation);*)
            raise Exception.Create('Not Implemented');
        end;
    end;

    var output_shape := Tensorflow.tf.shape(output);
    var target_rank  := target.shape.ndim;
    var update_shape := (target_rank > -1) and (output_rank > -1) and (target_rank <> output_rank - 1);
    if update_shape then
    begin
        target := Tensorflow.tf.reshape(target, -1);
        output := Tensorflow.tf.reshape(output, TFShape.Create([ -1, output.shape[-1] ]));
    end;

    if Assigned(ignore_class) then
       raise Exception.Create('Not Implemented');

    var res := Tensorflow.tf.nn.sparse_softmax_cross_entropy_with_logits(target, output);

    if Assigned(ignore_class) then
      raise Exception.Create('Not Implemented');

    if (update_shape) and (output_rank >= 3)  then
    begin
        // If our output includes timesteps or
        // spatial dimensions we need to reshape
        res := Tensorflow.tf.reshape(res, output_shape[':-1']);
    end;

    Result := res;

end;

function BackendImpl.spatial_2d_padding(x: TFTensor; padding: TNDArray; data_format: string): TFTensor;
var
  padArray   : TArray< TArray<Integer> >;
  pattern    : TNDArray;
  loc_padding: NDArray;
begin
    if padding = nil then
    begin
        padArray := [ [ 1, 1 ], [ 1, 1 ] ] ;
        padding  := TNDArray.Create(padArray);
    end;

    loc_padding := padding;

    if data_format = 'channels_first' then
    begin
        padArray := [ [ 0, 0 ], [ 0, 0 ], [ loc_padding[0][0] , loc_padding[0][1] ],
                                          [ loc_padding[1][0] , loc_padding[1][1] ] ];
        pattern := TNDArray.Create(padArray);
    end else
    begin
        padArray := [ [ 0, 0 ], [ loc_padding[0][0] , loc_padding[0][1] ],
                                [ loc_padding[1][0] , loc_padding[1][1] ], [ 0, 0 ] ];
        pattern := TNDArray.Create(padArray);
    end;
    Result := array_ops.pad(x, pattern);
end;

function BackendImpl.eval_in_eager_or_function(outputs: TFTensors): TNDArray;
begin
    if outputs[0].op.Tipo = 'Const' then
        Exit( TUtils.constant_value(outputs.First) );

    var source_graph := outputs.graph;
    var exec_graph   := _scratch_graph;
    var global_graph := get_graph;
    if (source_graph = global_graph) and (exec_graph <> global_graph) then
    begin
        SubGraphUtility.lift_to_graph(outputs, exec_graph, TList<TFTensor>.Create, true, true, source_graph);
    end;
    if (outputs[0].op.Tipo = 'Placeholder') or (outputs[0].op.Tipo = 'StridedSlice') then
    begin
        Result := exec_graph.external_captures[High(exec_graph.external_captures)].numpy;
        Exit;
    end;

    // Consolidate updates
    exec_graph.as_default;
    exec_graph.Inputs  := TFTensors.Create(exec_graph.internal_captures);
    exec_graph.Outputs := outputs;

    ConcreteFunction.Create(exec_graph);

    _CURRENT_SCRATCH_GRAPH := nil;
    Tensorflow.tf.Context.restore_mode;
    // return outputs.eval();
    raise Exception.Create('Not ImplementedException');
end;

function BackendImpl.binary_crossentropy(target, output: TFTensor; from_logits: Boolean): TFTensor;
begin
    if from_logits then
    begin
        Result := Tensorflow.tf.nn.sigmoid_cross_entropy_with_logits(target, output);
        Exit;
    end;

    var epsilon_ := constant_op.constant(epsilon(), TDTypes.as_base_dtype(output.dtype),'Const');
    output       := Tensorflow.tf.clip_by_value(output, epsilon_, Single(1.0) - TTensor(epsilon_));
    // Compute cross entropy from probabilities.
    var bce : TTensor := TTensor(target) * Tensorflow.tf.math.log(TTensor(output) + epsilon);
    bce := bce + (1 - TTensor(target)) * Tensorflow.tf.math.log(1 - TTensor(output) + epsilon());
    Result := -bce;
end;

function BackendImpl.categorical_crossentropy(target, output: TFTensor; from_logits: Boolean; axis: Integer): TFTensor;
begin
    if from_logits then
    begin
        Result := Tensorflow.tf.nn.softmax_cross_entropy_with_logits_v2(target, output, axis);
        Exit;
    end;

    if (output.op <> nil) and (output.op.tipo = 'Softmax') then
    begin
        if output.op.inputs.Count <> 1 then raise Exception.Create('');
        var o := output.op.inputs[0];
        Result := Tensorflow.tf.nn.softmax_cross_entropy_with_logits_v2(target, o, axis);
        Exit;
    end;

    // scale preds so that the class probas of each sample sum to 1
    output := TTensor(output) / math_ops.reduce_sum(output, TAxis(axis), true);
    // Compute cross entropy from probabilities.
    var epsilon_ := constant_op.constant(epsilon, Tdtypes.as_base_dtype(output.dtype),'Const');
    output       := clip_ops.clip_by_value(output, epsilon_, Single(1.0) - TTensor(epsilon_));
    Result := - TTensor(math_ops.reduce_sum( TTensor(target) * math_ops.log(output), TAxis(axis) ));
end;

function BackendImpl.resize_images(x: TFTensor; height_factor, width_factor: Integer; data_format, interpolation: string): TFTensor;
begin
    var rows : Integer;
    var cols : Integer;

    if data_format = 'channels_first' then
    begin
        rows := 2;
        cols := 3;
    end
    else if data_format = 'channels_last' then
    begin
        rows := 1;
        cols := 2;
    end else
        raise Exception.Create('Invalid `data_format` argument:' + data_format);

    var original_shape := x.shape;
    var new_shape      := array_ops.shape(x)[ [Slice.Create(rows, cols + 1)] ];
    new_shape          := TTensor(new_shape) * constant_op.constant( np.np_array<Integer>([height_factor, width_factor]) );

    if data_format = 'channels_first' then
        // x = permute_dimensions(x, [0, 2, 3, 1]);
        raise Exception.Create('Not Implemented');
    if interpolation = 'nearest' then
        x := Tensorflow.tf.image.resize_images_v2(x, new_shape, ResizeMethod.NEAREST_NEIGHBOR);

    if data_format = 'channels_first' then
        // x = permute_dimensions(x, [0, 3, 1, 2]);
        raise Exception.Create('Not Implemented');

    var new_height : Integer;
    var new_width : Integer;
    if original_shape[rows] < 0 then new_height := -1
    else                             new_height := original_shape[rows] * height_factor;

    if original_shape[cols] < 0 then new_width := -1
    else                             new_width := original_shape[cols] * width_factor;

    var output_shape : TFShape;
    if data_format = 'channels_first' then output_shape := TFShape.Create([-1, -1, new_height, new_width])
    else                                   output_shape := TFShape.Create([-1, new_height, new_width, -1]);

    x.shape := output_shape;
    Result := x;
end;

function BackendImpl.concatenate(tensors: TFTensors; axis: Integer): TFTensor;
begin
    if axis < 0 then
    begin
        var rank := tensors[0].ndim;
        if rank > -1 then
            axis := axis + rank
        else
            axis := 0;
    end;

    Result := array_ops.concat(tensors.ToArray, axis);
end;

function BackendImpl.conv2d_transpose(x: TFTensor; kernel: IVariableV1; output_shape: TFTensor; strides: PTFShape; padding, data_format: string;
  dilation_rate: PTFShape): TFTensor;
begin
    (*
    var force_transpose = false;
    if (data_format == "channels_first" && !dilation_rate.Equals(new[] { 1, 1 }))
        force_transpose = true;
    x, tf_data_format = _preprocess_conv2d_input(x, data_format, force_transpose)
    *)
    var tf_data_format : string := 'NHWC';
    padding := padding.ToUpper;
    var _strides := strides^;
    _strides := TFShape.Create([1, _strides[0], _strides[1], 1]);
    if dilation_rate^ = TFShape.Create([ 1, 1] ) then
        x := nn_impl.conv2d_transpose(x, kernel, output_shape,@_strides, padding, tf_data_format)
    else
        raise Exception.Create('dilation_rate other than [1,1] is not yet supported');

    Result := x;

end;

end.

