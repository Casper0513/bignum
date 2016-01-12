(** Arbitrary-precision rational numbers. *)
open Core_kernel.Std

type t

(** Sexp conversions represent values as decimals of up to nine decimal places if
    possible, or else as [(x + y/z)] where [x] is decimal and [y] and [z] are integers. So
    for example, 1/3 <-> (0.333333333 + 1/3000000000).  In string and sexp conversions,
    values with denominator of zero are special-cased: 0/0 <-> "nan", 1/0 <-> "inf", and
    -1/0 <-> "-inf". *)
include Sexpable       with type t := t
include Comparable     with type t := t
include Floatable      with type t := t
include Hashable       with type t := t
include Binable        with type t := t
include Quickcheckable with type t := t

val zero     : t
val one      : t
val ten      : t
val hundred  : t
val thousand : t
val million  : t
val billion  : t
val trillion : t

val tenth      : t
val hundredth  : t
val thousandth : t
val millionth  : t
val billionth  : t
val trillionth : t

val ( + )    : t -> t -> t
val ( - )    : t -> t -> t
val ( / )    : t -> t -> t
val ( * )    : t -> t -> t
(** Beware: [2 ** 8_000_000] will take at least a megabyte to store the result,
    and multiplying numbers a megabyte long is slow no matter how clever your algorithm.
    Be careful to ensure the second argument is reasonably-sized. *)
val ( ** )   : t -> int -> t
val abs      : t -> t
val neg      : t -> t
val inverse  : t -> t
val sum      : t list -> t

(** Default rounding direction is [`Nearest].
    [to_multiple_of] defaults to [one] and must not be [zero]. *)
val round
  :  ?dir:[ `Down | `Up | `Nearest | `Zero ]
  -> ?to_multiple_of:t
  -> t -> t

(** [None] if the result would overflow or [to_multiple_of] is zero. *)
val iround
  :  ?dir:[ `Down | `Up | `Nearest | `Zero ]
  -> ?to_multiple_of:int
  -> t -> int option

val round_as_bigint
  :  ?dir:[ `Down | `Up | `Nearest | `Zero ]
  -> ?to_multiple_of:Bigint.t
  -> t -> Bigint.t option

(** Exception if the result would overflow or [to_multiple_of] is zero. *)
val iround_exn
  :  ?dir:[ `Down | `Up | `Nearest | `Zero ]
  -> ?to_multiple_of:int
  -> t -> int

val round_as_bigint_exn
  :  ?dir:[ `Down | `Up | `Nearest | `Zero ]
  -> ?to_multiple_of:Bigint.t
  -> t -> Bigint.t

(** Convenience wrapper around [round] to round to the specified number
    of decimal digits. *)
val round_decimal
  :  ?dir:[ `Down | `Up | `Nearest | `Zero ]
  -> digits:int
  -> t -> t

(** Decimal. Output is truncated (not rounded) to nine decimal places, so may be lossy.
    Consider using [sexp_of_t] if you need lossless stringification. *)
val to_string  : t -> string
val to_float   : t -> float
(** Rounds toward zero. [None] if the conversion would overflow *)
val to_int     : t -> int option
val to_int_exn : t -> int
val is_zero    : t -> bool
val sign       : t -> int

val of_string : string -> t
val of_int    : int -> t
val of_float  : float -> t

(** [num t] returns the numerator of the numeric *)
val num : t -> t

(** [den t] returns the denominator of the numeric *)
val den : t -> t

val of_bigint : Bigint.t -> t
val num_as_bigint : t -> Bigint.t
val den_as_bigint : t -> Bigint.t

val pp : Format.formatter -> t -> unit

(** [gen_between ~with_undefined ~lower_bound ~upper_bound] generates a Quickcheck
    generator like [gen], but restricted to values satisfying [lower_bound] and
    [upper_bound], plus the undefined value if [with_undefined] is true.  If no values
    satisfy [lower_bound] and [upper_bound], raises an exception. *)
val gen_between
  :  with_undefined : bool
  -> lower_bound    : t Maybe_bound.t
  -> upper_bound    : t Maybe_bound.t
  -> t Quickcheck.Generator.t

module Stable : sig
  module V1 : sig
    type nonrec t = t [@@deriving sexp, bin_io, compare]
  end
  module V2 : sig
    type nonrec t = t [@@deriving sexp, bin_io, compare]
  end
end

module O : sig

  (* If you want to add values here, you need to make sure that it won't create unexpected
  behavior in modules that use this. For instance, if you want to add "val qty : t" here,
  then you might be creating unexpected behavior in modules that had Bignum.(qty /
  thousand *)

  val ( + )    : t -> t -> t
  val ( - )    : t -> t -> t
  val ( / )    : t -> t -> t
  val ( * )    : t -> t -> t
  val ( ** )   : t -> int -> t
  val abs      : t -> t
  val neg      : t -> t

  include Core_kernel.Polymorphic_compare_intf.Infix with type t := t

  val zero     : t
  val one      : t
  val ten      : t
  val hundred  : t
  val thousand : t
  val million  : t
  val billion  : t
  val trillion : t

  val tenth      : t
  val hundredth  : t
  val thousandth : t
  val millionth  : t
  val billionth  : t
  val trillionth : t

  val of_int    : int -> t
  val of_float  : float -> t
end
