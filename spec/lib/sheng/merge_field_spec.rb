describe Sheng::MergeField do
  subject {
    fragment = xml_fragment('input/merge_field')
    element = fragment.xpath("//w:fldSimple[contains(@w:instr, 'MERGEFIELD')]").first
    described_class.new(element)
  }

  describe '#raw_key' do
    it 'returns the mergefield name from the element' do
      expect(subject.raw_key).to eq 'ocean.fishy'
    end
  end

  describe '#key' do
    it 'returns the raw key with start metadata stripped off' do
      allow(subject).to receive(:raw_key).and_return('start:whipple.dooter')
      expect(subject.key).to eq 'whipple.dooter'
    end

    it 'returns the raw key with end metadata stripped off' do
      allow(subject).to receive(:raw_key).and_return('end:smock.fortuna')
      expect(subject.key).to eq 'smock.fortuna'
    end

    it 'returns the raw key as is if no start or end token' do
      allow(subject).to receive(:raw_key).and_return('ouch_i_hate.frisbees')
      expect(subject.key).to eq 'ouch_i_hate.frisbees'
    end
  end
end