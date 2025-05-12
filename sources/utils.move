module hackermove::utils {
    use std::string;
    use std::string::String;
    use std::vector;

    const E_INVALID_DATE_FORMAT: u64 = 0;

    public fun date_formatter(month: String, day: String, year: String): String {
        let date = vector::empty<u8>();

        let delimiter = vector::empty<u8>();
        delimiter.append(b"/");

        date.append(*month.bytes());
        date.append(delimiter);
        date.append(*day.bytes());
        date.append(delimiter);
        date.append(*year.bytes());

        string::utf8(date)
    }

    #[test]
    public fun test_date_formatter(){
        let month = string::utf8(b"02");
        let day = string::utf8(b"02");
        let year = string::utf8(b"1998");

        let date = date_formatter(month, day, year);

        assert!(date == string::utf8(b"02/02/1998"), E_INVALID_DATE_FORMAT)
    }

    #[test]
    #[expected_failure]
    public fun test_invalid_date_format(){
        let month = string::utf8(b"02");
        let day = string::utf8(b"02");
        let year = string::utf8(b"1998");

        let date = date_formatter(month, day, year);

        assert!(date == string::utf8(b"02-02-1998"), E_INVALID_DATE_FORMAT)
    }
}
