(** [get_daily_index count] returns a deterministic index based on the current date.
    the index is in the range [0, count).
    guaranteed to return the same index for the same date.
    samples from a predefined cycle of length [count] that is shuffled 
    using a seeded Fisher-Yates algorithm.
    @param   count the total number of items to choose from
    @return  an index between 0 and count-1 *)
val get_daily_index : int -> int
