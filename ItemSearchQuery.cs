namespace SimpleSearch
{
    public class ItemSearchQuery
    {
        public string? Search { get; set; }
        public string? Category { get; set; }

        public DateTime? From { get; set; }
        public DateTime? To { get; set; }

        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;

        public string SortBy { get; set; } = "CreatedAt";
        public bool Desc { get; set; } = true;
    }
}
