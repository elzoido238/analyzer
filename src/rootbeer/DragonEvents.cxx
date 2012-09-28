/// \file DragonEvents.cxx
/// \author G. Christian
/// \brief Implements DragonEvents.hxx
#include "utils/Error.hxx"
#include "DragonEvents.hxx"


// ======== Class dragon::GammaEvent ======== //

rootbeer::GammaEvent::GammaEvent():
	fGamma("gamma", this, true, "") { }

void rootbeer::GammaEvent::HandleBadEvent()
{
	dragon::err::Error("GammaEvent")
		<< "Unknown error encountered during event processing";
}

Bool_t rootbeer::GammaEvent::DoProcess(const void* addr, Int_t nchar)
{
  /*!
	 * Calls unpacking routines of dragon::Head to extract the raw MIDAS
	 * data into a dragon::Head structure. Then calculates higher-level
	 * parameters.
	 */
	if(!addr) {
		dragon::err::Error("rootbeer::GammaEvent::DoProcess") << "Received NULL event address";
		return false;
	}

	fGamma->unpack( *(AsMidasEvent(addr)) );
	fGamma->calculate();

	return true;
}


// ======== Class dragon::HeavyIonEvent ======== //

rootbeer::HeavyIonEvent::HeavyIonEvent():
	fHeavyIon("hi", this, true, "") { }

void rootbeer::HeavyIonEvent::HandleBadEvent()
{
	dragon::err::Error("HeavyIonEvent")
		<< "Unknown error encountered during event processing";
}

Bool_t rootbeer::HeavyIonEvent::DoProcess(const void* addr, Int_t nchar)
{
  /*!
	 * Calls unpacking routines of dragon::Tail to extract the raw MIDAS
	 * data into a dragon::Head structure. Then calculates higher-level
	 * parameters.
	 */
	if(!addr) {
		dragon::err::Error("rootbeer::HeavyIonEvent::DoProcess") << "Received NULL event address";
		return false;
	}

	fHeavyIon->unpack( *(AsMidasEvent(addr)) );
	fHeavyIon->calculate();

	return true;
}


// ======== Class dragon::CoincEvent ======== //

rootbeer::CoincEvent::CoincEvent():
	fCoinc("coinc", this, false, "") { }

void rootbeer::CoincEvent::HandleBadEvent()
{
	dragon::err::Error("CoincEvent")
		<< "Unknown error encountered during event processing";
}

Bool_t rootbeer::CoincEvent::DoProcess(const void* addr, Int_t nchar)
{
	/*!
	 * Unpacks data from the head and tail MIDAS events into the corresponding
	 * fields of fDragon, then calls the calculate() methods of each.
	 * \todo Figure out a way to handle this without unpacking the events; in principle,
	 * they should have already been handled as singles events, thus we add extra overhead
	 * by going through the unpacking routines twice - it should be possible to buffer and
	 * then copy the already-unpacked head and tail structures directly.
	 */
	if(!addr) {
		dragon::err::Error("rootbeer::CoincEvent::DoProcess") << "Received NULL event address";
		return false;
	}

	const midas::Event& midasHead = *(AsCoincMidasEvent(addr)->fGamma);
	const midas::Event& midasTail = *(AsCoincMidasEvent(addr)->fHeavyIon);

	fCoinc->head.unpack(midasHead);
	fCoinc->tail.unpack(midasTail);
	
	fCoinc->head.calculate();
	fCoinc->tail.calculate();

	fCoinc->calculate();

	return true;
}

